#!/usr/bin/env bash
# tool-tracker.sh — Track last tool action for Ghostty tab title
# PreToolUse hook (catch-all). Writes short action description to state file.
trap 'exit 0' ERR

# Tool name + input come via stdin JSON
STDIN=$(cat)
TOOL=$(echo "$STDIN" | jq -r '.tool_name // ""' 2>/dev/null)
[[ -z "$TOOL" || "$TOOL" == "null" ]] && TOOL="${CLAUDE_TOOL_NAME:-unknown}"
INPUT=$(echo "$STDIN" | jq -r '.tool_input // ""' 2>/dev/null)
[[ -z "$INPUT" || "$INPUT" == "null" ]] && INPUT="${CLAUDE_TOOL_INPUT:-}"

case "$TOOL" in
  Read|Write|Edit)
    target=$(echo "$INPUT" | jq -r '.file_path // ""' 2>/dev/null)
    [[ -n "$target" ]] && target=$(basename "$target") || target=""
    action="$TOOL $target"
    ;;
  Bash)
    cmd=$(echo "$INPUT" | jq -r '.command // ""' 2>/dev/null | head -c 25)
    action="\$ $cmd"
    ;;
  Grep)
    pat=$(echo "$INPUT" | jq -r '.pattern // ""' 2>/dev/null | head -c 15)
    action="Grep $pat"
    ;;
  Glob)
    pat=$(echo "$INPUT" | jq -r '.pattern // ""' 2>/dev/null | head -c 15)
    action="Glob $pat"
    ;;
  Agent)
    desc=$(echo "$INPUT" | jq -r '.description // ""' 2>/dev/null | head -c 20)
    action="Agent: $desc"
    ;;
  mcp__*)
    short=$(echo "$TOOL" | sed 's/mcp__//;s/__/:/g;s/_exa$//;s/web_search/search/' | head -c 15)
    action="$short"
    ;;
  *)
    action="$TOOL"
    ;;
esac

# Reset agent cascade counter when a non-Agent tool fires
if [ "$TOOL" != "Agent" ]; then
    date +%s > "/tmp/claude-non-agent-$PPID" 2>/dev/null || true
fi

# Duplicate-read detection: warn if same file read within last 20 tool calls (recency window).
# Old approach warned for entire session — 75+ false positives/day from post-compaction re-reads.
READS_FILE="/tmp/claude-reads-$PPID"
COUNTER_FILE="/tmp/claude-toolcount-$PPID"
WARN=""
BLOCK=0
# Increment global tool counter
TOOL_COUNT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
TOOL_COUNT=$((TOOL_COUNT + 1))
echo "$TOOL_COUNT" > "$COUNTER_FILE" 2>/dev/null || true
RECENCY_WINDOW=20

if [ "$TOOL" = "Read" ]; then
    fpath=$(echo "$INPUT" | jq -r '.file_path // ""' 2>/dev/null)
    has_offset=$(echo "$INPUT" | jq -r '.offset // empty' 2>/dev/null)
    if [ -n "$fpath" ] && [ -f "$READS_FILE" ]; then
        # Chunked reads (with offset) are the expected pattern for large files — only count
        # full-file reads (no offset) as potential duplicates. Offset reads get a separate key.
        if [ -n "$has_offset" ]; then
            dedup_key="${fpath}@${has_offset}"
        else
            dedup_key="$fpath"
        fi
        # Count total full-file reads (no offset) of this file
        TOTAL_READS=$(grep -cxF "$fpath" <(cut -d'|' -f1 "$READS_FILE") 2>/dev/null || echo 0)

        if [ -z "$has_offset" ] && [ "$TOTAL_READS" -ge 4 ]; then
            # Blocking: 4+ full-file reads is almost certainly wasteful (shadow data: 302 triggers at ≥4)
            WARN="BLOCKED: ${fpath##*/} read ${TOTAL_READS}x this session (full file). Content is in context. Use offset/limit for a specific section, or explain why you need the full content again."
            BLOCK=1
        elif [ -z "$has_offset" ] && [ "$TOTAL_READS" -ge 3 ]; then
            # Moderate: 3 full-file reads likely redundant
            WARN="REPEATED READ (${TOTAL_READS}x): ${fpath##*/} — content is likely still in context. Use offset/limit if you need a specific section."
        else
            # Original recency-window check for first repeat (same dedup key)
            PREV_COUNT=$(grep -F "$dedup_key" "$READS_FILE" 2>/dev/null | tail -1 | cut -d'|' -f2)
            if [ -n "$PREV_COUNT" ] && [ $((TOOL_COUNT - PREV_COUNT)) -lt $RECENCY_WINDOW ]; then
                WARN="DUPLICATE READ: ${fpath##*/} was read $((TOOL_COUNT - PREV_COUNT)) tool calls ago. The content is likely still in context."
            fi
        fi
    fi
    # Store dedup_key|counter (append; newest entry wins on lookup)
    dedup_key="${dedup_key:-$fpath}"
    [ -n "$fpath" ] && echo "${dedup_key}|${TOOL_COUNT}" >> "$READS_FILE" 2>/dev/null || true
elif [ "$TOOL" = "Write" ] || [ "$TOOL" = "Edit" ]; then
    # Clear the read entry for this file (edits invalidate cached reads)
    fpath=$(echo "$INPUT" | jq -r '.file_path // ""' 2>/dev/null)
    if [ -n "$fpath" ] && [ -f "$READS_FILE" ]; then
        { grep -vF "$fpath" "$READS_FILE" || true; } > "${READS_FILE}.tmp" 2>/dev/null; mv "${READS_FILE}.tmp" "$READS_FILE" 2>/dev/null || true
    fi
fi

echo "$action" > "/tmp/claude-tab-tool-$PPID" 2>/dev/null || true

if [ -n "$WARN" ]; then
    LEVEL="warn"
    [ "$BLOCK" = "1" ] && LEVEL="block"
    ~/Projects/skills/hooks/hook-trigger-log.sh "dup-read" "$LEVEL" "${fpath##*/}" 2>/dev/null || true
    SAFE_WARN=$(echo "$WARN" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read().strip()))' 2>/dev/null)
    [ -z "$SAFE_WARN" ] && SAFE_WARN="\"$(echo "$WARN" | tr '"' "'")\""
    echo "{\"additionalContext\": ${SAFE_WARN}}"
    # Shadow logging for ongoing calibration
    SHADOW_LOG="$HOME/.claude/dup-read-shadow.jsonl"
    printf '{"ts":"%s","file":"%s","reads":%s,"ppid":"%s","blocked":%s}\n' \
      "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "${fpath##*/}" "${TOTAL_READS:-1}" "$PPID" \
      "$([ "$BLOCK" = "1" ] && echo true || echo false)" >> "$SHADOW_LOG" 2>/dev/null || true
    [ "$BLOCK" = "1" ] && exit 2
fi

exit 0
