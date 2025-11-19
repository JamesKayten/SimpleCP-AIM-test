# AI BEHAVIOR RULES - READ FIRST

## MANDATORY BEHAVIOR
- **IMMEDIATE ACTION:** When task instructions exist, START WORK immediately
- **NO EXPLORATION:** Don't ask questions, explore directories, or offer options
- **DIRECT EXECUTION:** Execute the first specified task without delay
- **BE CONCISE:** Simple yes/no answers when asked simple questions
- **EFFICIENCY:** If task should take 20 minutes, finish in 20 minutes
- **CLEAN ORGANIZATION:** Keep files in logical directories, not project root

## COMMUNICATION STYLE
- **Direct and practical answers only**
- **No theoretical explanations**
- **No hype or marketing language**
- **Give exact paths/commands immediately when asked**

## PROJECT CONFIGURATION
- **Type:** Python Backend/API
- **File Size Limit:** 250 lines
- **Test Coverage:** 90%
- **Validation Tools:** black,flake8,pytest,pyperclip

## CURRENT WORK PATTERN
1. Read `.ai/CURRENT_TASK.md` for current assignment
2. Execute tasks in specified order
3. Update `.ai/CURRENT_TASK.md` when completed
4. Commit changes with clear messages

**CRITICAL:** Time is money. Work efficiently. Complete tasks quickly.

## ADDITIONAL MANDATORY RULES (Added from Session Analysis)

### VERIFICATION REQUIREMENTS
- **NEVER claim completion without thorough verification** - Check all file states, run all validation commands
- **Verify branch names exactly** - Do not guess or assume branch names, fetch and confirm
- **Test file existence before referencing** - Ensure all referenced files/directories actually exist

### INSTRUCTION PROTOCOLS
- **Always include 250-line file size limits** in ALL instructions to other AIs
- **Provide complete single prompts** - No multi-step confirmations, give all work in one comprehensive prompt
- **Maximize credit usage** - Give extensive work lists, don't limit to single options when multiple can be done
- **Include validation commands** - Always provide exact commands for verifying completion

### COMMUNICATION RESTRICTIONS
- **No algorithmic apologies** - Eliminate meaningless "I apologize" responses
- **No completion claims without proof** - Don't say "working correctly" without actual verification
- **Deliver prompts, not descriptions** - Provide copy/paste instructions, not explanations of what they'll do

### FILE SIZE ENFORCEMENT
- **250-line limit is NON-NEGOTIABLE** - Must be mentioned in every instruction
- **Block merges for violations** - No exceptions for file size limits
- **Use correct validation tools** - flake8 --max-line-length=88 (not 79)

### EFFICIENCY PRIORITIES
- **Credit maximization over perfectionism** - Give comprehensive work to burn credits efficiently
- **Complete verification before status updates** - Don't update task status until actually verified
- **Continuous execution instructions** - Tell AIs to work through multiple areas without stopping