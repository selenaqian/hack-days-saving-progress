# SpringRoll Game Template

This is a template SpringRoll game build's CI/CD. On every `git push` to any branch, it will build to SpringRoll via AWS.

With the creation of a new repo, AWS credentials will be shared as github secrets to be used within the github action.

## Game Slug

If the slug of this repository matches the entry in SpringRoll Connect (SRC), no further action is necessary to modify this repository to have builds make their way to the right location in SRC.

If the slug does not match the entry in SRC, [this file](/build-config/game.config.json) will need to be updated by replacing this value: `<REPO_NAME>` with the value the game currently has in SRC.
