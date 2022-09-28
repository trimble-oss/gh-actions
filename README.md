# Trimble GitHub actions

Common actions for `trimble-oss` repositories.

## How to write composite actions

See [GitHub documentation on actions](https://docs.github.com/en/actions/creating-actions/about-custom-actions)

Add a folder using the name the action will be used, for example, `mend-scanner` folder contains an action that will be referred to as `trimble-oss/gh-actions/mend-scanner@latest` in workflows.

Add every composite action to [dependabot configuration](.github/dependabot.yml).
