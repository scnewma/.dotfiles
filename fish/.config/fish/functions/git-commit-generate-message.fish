function git-commit-generate-message
    set -l instruction_file (mktemp)
    set -l commit_msg_file (mktemp)

    # Write markdown instructions to temp file
    echo "# Task

Generate a commit message for the following git diff. Do not use conventional commits format (e.g., feat:, fix:, docs:, etc.). Keep it concise and focus on WHAT changed and WHY.

DO NOT output any other information about the generation, only the commit message itself. Surround the commit message in Markdown code blocks (\`\`\`) to make it easily parsable.

# Git Diff

\`\`\`diff" > $instruction_file

    # Append the git diff for staged changes
    git diff --cached >> $instruction_file

    # Close the diff code block
    echo '```' >> $instruction_file

    # First strip all ANSI codes, then find content between code blocks
    goose run -i $instruction_file | sed 's/\x1b\[[0-9;]*[mGK]//g' | awk '/^```$/{p=!p;next} p{print}' > $commit_msg_file

    git commit --template=$commit_msg_file

    # Clean up
    rm $instruction_file
    rm $commit_msg_file
end