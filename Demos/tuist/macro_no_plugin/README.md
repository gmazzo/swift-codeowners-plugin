# Tuist integration without SPM plugin
There is a [known limitation](https://github.com/tuist/tuist/blob/main/server/priv/docs/en/guides/features/projects/dependencies.md#xcodes-default-integration-xcodes-default-integration) on Tust with the usage of SPM Build Plugins and makes
the overall DX less than ideal.

This demo shows up an alternative way to integrate the macro that replaces its behavior with a pre-build script
