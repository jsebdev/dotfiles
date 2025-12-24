# this should only work if in a git repository
# error out if not in a git repository
if [ ! -d .git ]; then
  echo "Error: This script must be run in a git repository."
  exit 1
fi

# backup current claude code files and directory
mv CLAUDE.md CLAUDE.md.bak
mv CLAUDE.local.md CLAUDE.local.md.bak
mv .claude .claude.bak

claude_branch_name="sebastian_claude_config"

# move to the sebastian_claude_config branch
git checkout $claude_branch_name

# delete the current claude code files and directory if they exist
rm -rf CLAUDE.md CLAUDE.local.md .claude

# copy back the backup files to original names
mv CLAUDE.md.bak CLAUDE.md
mv CLAUDE.local.md.bak CLAUDE.local.md
mv .claude.bak .claude

# git commit the changes with current date and time
git add CLAUDE.md CLAUDE.local.md .claude
git commit -m "Backup ignored Claude config files on $(date '+%Y-%m-%d %H:%M:%S')"


# return to the previous branch
git checkout -

# git apply the claude config 
git diff HEAD sebastian_claude_config -- CLAUDE.md CLAUDE.local.md .claude | git apply
