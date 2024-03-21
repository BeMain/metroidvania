## Inspiration
- [Sheepy](https://mrsuicidesheep.itch.io/sheepy)
- [Rainworld](https://store.steampowered.com/app/312520/Rain_World/)

## Git naming
### Commits
This project follows (since March 15 2024) the Conventional commits specification for naming commits. Here follows a short summary of that specification.

A commit message should be structured as follows:
```
<type>[(optional scope)]: <description>

[optional body]

[optional footer(s)]
```
The footer Fixes <issue number> can be used to reference a GitHub issue.

Here is an example: `feat(rendering): implement pixelation of nodes through a shader`

Commitizen is a command line tool that can be used to assist in creating commits that follows the Conventional commits specification.

### Branches
A feature branch should be named as follows:

feat/[optional issue reference]/<description>

The description should use dashes (-) to separate words.

Here's an example: `feat/issue72/configure-audio-session`
