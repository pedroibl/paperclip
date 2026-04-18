BASE=http://127.0.0.1:3100/api

CEO=260b3a65-2626-4c86-a561-40d1d064632e
CMO=83591b00-aa96-4ac0-9a43-9a87740b542a
CTO=1df6f2ac-53da-49a1-b917-a8512b796b84
DESIGNER=e62d8d88-56bd-431f-ad54-975ef0e2c0e8
COPYWRITER=d6415d3c-9f72-474d-89fd-920b03fb4386

# Run this block for each agent ID:
AGENT=$COPYWRITER  # change to each agent

curl -s "$BASE/agents/$AGENT/instructions-bundle/file?path=AGENTS.md" \
  | jq -r '.content' > /tmp/agents-tmp.md

cat >> /tmp/agents-tmp.md << 'EOF'

---

## Context Files

Read these files before doing any work:

- `./business-overview.md` — company overview, mission, targets, team structure
- `./mph-brand-style.md` — brand voice, colours, typography, tone of voice
EOF

curl -s -X PUT "$BASE/agents/$AGENT/instructions-bundle/file" \
  -H "Content-Type: application/json" \
  -d "{\"path\": \"AGENTS.md\", \"content\": $(cat /tmp/agents-tmp.md | jq -Rs .)}"

echo "Done: $AGENT"
