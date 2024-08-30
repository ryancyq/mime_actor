# Changelog

## [Unreleased](https://github.com/ryancyq/mime_actor/tree/HEAD)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.7.2...HEAD)

**Merged pull requests:**

- chore\(deps-dev\): bump rexml from 3.3.5 to 3.3.6 [\#75](https://github.com/ryancyq/mime_actor/pull/75) ([dependabot[bot]](https://github.com/apps/dependabot))
- lib: rspec-activesupport [\#73](https://github.com/ryancyq/mime_actor/pull/73) ([ryancyq](https://github.com/ryancyq))

## [v0.7.2](https://github.com/ryancyq/mime_actor/tree/v0.7.2) (2024-08-18)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.7.1...v0.7.2)

**Merged pull requests:**

- chore\(deps\): bump activesupport from 7.1.3.4 to 7.2.0 [\#71](https://github.com/ryancyq/mime_actor/pull/71) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.7.1](https://github.com/ryancyq/mime_actor/tree/v0.7.1) (2024-07-31)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.7.0...v0.7.1)

**Implemented enhancements:**

- use tagged logging [\#64](https://github.com/ryancyq/mime_actor/issues/64)

**Closed issues:**

- generate change log [\#1](https://github.com/ryancyq/mime_actor/issues/1)

**Merged pull requests:**

- lib: generate CHANGELOG.md [\#67](https://github.com/ryancyq/mime_actor/pull/67) ([ryancyq](https://github.com/ryancyq))
- feat: tagged logging [\#66](https://github.com/ryancyq/mime_actor/pull/66) ([ryancyq](https://github.com/ryancyq))
- refactor: code generator with heredoc [\#65](https://github.com/ryancyq/mime_actor/pull/65) ([ryancyq](https://github.com/ryancyq))

## [v0.7.0](https://github.com/ryancyq/mime_actor/tree/v0.7.0) (2024-07-30)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.6.4...v0.7.0)

**Merged pull requests:**

- fix: callback chain sequence respect definition ordering [\#63](https://github.com/ryancyq/mime_actor/pull/63) ([ryancyq](https://github.com/ryancyq))
- refactor: callback generator [\#62](https://github.com/ryancyq/mime_actor/pull/62) ([ryancyq](https://github.com/ryancyq))
- feat: \#act\_on\_action to replace \#respond\_act\_to [\#61](https://github.com/ryancyq/mime_actor/pull/61) ([ryancyq](https://github.com/ryancyq))
- fix: action/format validation [\#60](https://github.com/ryancyq/mime_actor/pull/60) ([ryancyq](https://github.com/ryancyq))

## [v0.6.4](https://github.com/ryancyq/mime_actor/tree/v0.6.4) (2024-07-26)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.6.3...v0.6.4)

**Implemented enhancements:**

- Use actor name generator [\#5](https://github.com/ryancyq/mime_actor/issues/5)

**Merged pull requests:**

- feat: actor delegator [\#57](https://github.com/ryancyq/mime_actor/pull/57) ([ryancyq](https://github.com/ryancyq))
- lib: add railtie for deprecation config [\#56](https://github.com/ryancyq/mime_actor/pull/56) ([ryancyq](https://github.com/ryancyq))
- lib: extract deprecation into separate file [\#55](https://github.com/ryancyq/mime_actor/pull/55) ([ryancyq](https://github.com/ryancyq))
- refactor: rename with validator into callable validator [\#54](https://github.com/ryancyq/mime_actor/pull/54) ([ryancyq](https://github.com/ryancyq))
- chore\(deps-dev\): bump rubocop from 1.64.1 to 1.65.0 [\#35](https://github.com/ryancyq/mime_actor/pull/35) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.6.3](https://github.com/ryancyq/mime_actor/tree/v0.6.3) (2024-07-25)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.6.2...v0.6.3)

**Merged pull requests:**

- fix: validate format arg for \#cue\_actor [\#53](https://github.com/ryancyq/mime_actor/pull/53) ([ryancyq](https://github.com/ryancyq))
- fix: use controller\#action\_name [\#52](https://github.com/ryancyq/mime_actor/pull/52) ([ryancyq](https://github.com/ryancyq))
- feat: rescue act callbacks [\#51](https://github.com/ryancyq/mime_actor/pull/51) ([ryancyq](https://github.com/ryancyq))
- lib: allow actor of any visibility to be called [\#50](https://github.com/ryancyq/mime_actor/pull/50) ([ryancyq](https://github.com/ryancyq))
- feat: run act callbacks during `start_scene` [\#49](https://github.com/ryancyq/mime_actor/pull/49) ([ryancyq](https://github.com/ryancyq))
- spec: add act callbacks test sequence [\#48](https://github.com/ryancyq/mime_actor/pull/48) ([ryancyq](https://github.com/ryancyq))
- fix: support collection argument for  action/format filters in act\_callacbks configuration [\#47](https://github.com/ryancyq/mime_actor/pull/47) ([ryancyq](https://github.com/ryancyq))
- refactor: move action collection vs single action rule into a composed rule in validator [\#46](https://github.com/ryancyq/mime_actor/pull/46) ([ryancyq](https://github.com/ryancyq))
- refactor: dispatcher callable API [\#45](https://github.com/ryancyq/mime_actor/pull/45) ([ryancyq](https://github.com/ryancyq))
- Revert "Revert "feat: act callbacks"" [\#44](https://github.com/ryancyq/mime_actor/pull/44) ([ryancyq](https://github.com/ryancyq))
- doc: example controller spec [\#31](https://github.com/ryancyq/mime_actor/pull/31) ([ryancyq](https://github.com/ryancyq))

## [v0.6.2](https://github.com/ryancyq/mime_actor/tree/v0.6.2) (2024-07-21)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.6.1...v0.6.2)

**Implemented enhancements:**

- feat: act callbacks [\#32](https://github.com/ryancyq/mime_actor/issues/32)

**Merged pull requests:**

- Revert "feat: act callbacks" [\#43](https://github.com/ryancyq/mime_actor/pull/43) ([ryancyq](https://github.com/ryancyq))
- feat: act callbacks [\#42](https://github.com/ryancyq/mime_actor/pull/42) ([ryancyq](https://github.com/ryancyq))
- chore: deprecate methods before removal [\#41](https://github.com/ryancyq/mime_actor/pull/41) ([ryancyq](https://github.com/ryancyq))
- lib: instance method rescue\_actor to public [\#40](https://github.com/ryancyq/mime_actor/pull/40) ([ryancyq](https://github.com/ryancyq))
- refactor: replace dispatch\_act rescue with dispatch\_actor rescue [\#39](https://github.com/ryancyq/mime_actor/pull/39) ([ryancyq](https://github.com/ryancyq))
- refactor: dispatcher call [\#38](https://github.com/ryancyq/mime_actor/pull/38) ([ryancyq](https://github.com/ryancyq))
- lib: add gem deprecation message [\#37](https://github.com/ryancyq/mime_actor/pull/37) ([ryancyq](https://github.com/ryancyq))
- lib: keep version as string [\#36](https://github.com/ryancyq/mime_actor/pull/36) ([ryancyq](https://github.com/ryancyq))
- fix: use `module_eval` inside module [\#34](https://github.com/ryancyq/mime_actor/pull/34) ([ryancyq](https://github.com/ryancyq))
- fix: use `#dispatch_act` [\#33](https://github.com/ryancyq/mime_actor/pull/33) ([ryancyq](https://github.com/ryancyq))

## [v0.6.1](https://github.com/ryancyq/mime_actor/tree/v0.6.1) (2024-07-03)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.6.0...v0.6.1)

**Implemented enhancements:**

- allow block via scene composition [\#2](https://github.com/ryancyq/mime_actor/issues/2)
- feat: actor responder [\#28](https://github.com/ryancyq/mime_actor/pull/28) ([ryancyq](https://github.com/ryancyq))
- fix: error message should use `#inspect` for param [\#27](https://github.com/ryancyq/mime_actor/pull/27) ([ryancyq](https://github.com/ryancyq))
- fix: rubocop access modifier [\#26](https://github.com/ryancyq/mime_actor/pull/26) ([ryancyq](https://github.com/ryancyq))
- refactor: rescue validation + dispatch [\#25](https://github.com/ryancyq/mime_actor/pull/25) ([ryancyq](https://github.com/ryancyq))
- fix: switch back to ClassMethods [\#24](https://github.com/ryancyq/mime_actor/pull/24) ([ryancyq](https://github.com/ryancyq))
- fix: require active support `nil` class extension [\#23](https://github.com/ryancyq/mime_actor/pull/23) ([ryancyq](https://github.com/ryancyq))
- fix: ensure validation message use \#inspect  [\#22](https://github.com/ryancyq/mime_actor/pull/22) ([ryancyq](https://github.com/ryancyq))
- refactor: act\_on\_format with respond\_act\_to [\#21](https://github.com/ryancyq/mime_actor/pull/21) ([ryancyq](https://github.com/ryancyq))

**Merged pull requests:**

- fix: ensure `actor` passed to `#cue_actor` is executed within the instance [\#30](https://github.com/ryancyq/mime_actor/pull/30) ([ryancyq](https://github.com/ryancyq))
- fix: update type check logic to raise `TypeError` instead [\#29](https://github.com/ryancyq/mime_actor/pull/29) ([ryancyq](https://github.com/ryancyq))

## [v0.6.0](https://github.com/ryancyq/mime_actor/tree/v0.6.0) (2024-07-01)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.5.4...v0.6.0)

**Implemented enhancements:**

- fix: refactor rescue validations [\#20](https://github.com/ryancyq/mime_actor/pull/20) ([ryancyq](https://github.com/ryancyq))
- fix: switch over to active support class methods [\#19](https://github.com/ryancyq/mime_actor/pull/19) ([ryancyq](https://github.com/ryancyq))
- fix: use `#rescue_act_from` [\#17](https://github.com/ryancyq/mime_actor/pull/17) ([ryancyq](https://github.com/ryancyq))
- fix: promote `#act_on_format` to the public API [\#16](https://github.com/ryancyq/mime_actor/pull/16) ([ryancyq](https://github.com/ryancyq))

**Merged pull requests:**

- refactor: top level comments [\#18](https://github.com/ryancyq/mime_actor/pull/18) ([ryancyq](https://github.com/ryancyq))

## [v0.5.4](https://github.com/ryancyq/mime_actor/tree/v0.5.4) (2024-06-29)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.5.3...v0.5.4)

**Implemented enhancements:**

- fix: alias compose\_scene to act\_on\_format [\#15](https://github.com/ryancyq/mime_actor/pull/15) ([ryancyq](https://github.com/ryancyq))

## [v0.5.3](https://github.com/ryancyq/mime_actor/tree/v0.5.3) (2024-06-29)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.5.2...v0.5.3)

## [v0.5.2](https://github.com/ryancyq/mime_actor/tree/v0.5.2) (2024-06-29)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.5.1...v0.5.2)

**Implemented enhancements:**

- fix: ensure block is passed when calling dispatch\_cue [\#13](https://github.com/ryancyq/mime_actor/pull/13) ([ryancyq](https://github.com/ryancyq))

**Closed issues:**

- document API  [\#4](https://github.com/ryancyq/mime_actor/issues/4)

**Merged pull requests:**

- doc: update class/methods with rdoc compatible comments [\#14](https://github.com/ryancyq/mime_actor/pull/14) ([ryancyq](https://github.com/ryancyq))
- chore\(deps-dev\): bump simplecov from 0.21.2 to 0.22.0 [\#12](https://github.com/ryancyq/mime_actor/pull/12) ([dependabot[bot]](https://github.com/apps/dependabot))

## [v0.5.1](https://github.com/ryancyq/mime_actor/tree/v0.5.1) (2024-06-28)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.4.0...v0.5.1)

**Implemented enhancements:**

- fix: refine logging message to be clearer in context [\#10](https://github.com/ryancyq/mime_actor/pull/10) ([ryancyq](https://github.com/ryancyq))
- spec: add tests for different type of error class [\#9](https://github.com/ryancyq/mime_actor/pull/9) ([ryancyq](https://github.com/ryancyq))
- spec: add tests to logging module [\#7](https://github.com/ryancyq/mime_actor/pull/7) ([ryancyq](https://github.com/ryancyq))
- spec: improve coverage [\#6](https://github.com/ryancyq/mime_actor/pull/6) ([ryancyq](https://github.com/ryancyq))

**Merged pull requests:**

- spec: add action controller specific test [\#11](https://github.com/ryancyq/mime_actor/pull/11) ([ryancyq](https://github.com/ryancyq))
- spec: add tests around rescue handler invocation context [\#8](https://github.com/ryancyq/mime_actor/pull/8) ([ryancyq](https://github.com/ryancyq))

## [v0.4.0](https://github.com/ryancyq/mime_actor/tree/v0.4.0) (2024-06-27)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.3.3...v0.4.0)

**Implemented enhancements:**

- handle Mime::ALL priority [\#3](https://github.com/ryancyq/mime_actor/issues/3)

## [v0.3.3](https://github.com/ryancyq/mime_actor/tree/v0.3.3) (2024-06-24)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.3.2...v0.3.3)

## [v0.3.2](https://github.com/ryancyq/mime_actor/tree/v0.3.2) (2024-06-24)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.3.1...v0.3.2)

## [v0.3.1](https://github.com/ryancyq/mime_actor/tree/v0.3.1) (2024-06-23)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.3.0...v0.3.1)

## [v0.3.0](https://github.com/ryancyq/mime_actor/tree/v0.3.0) (2024-06-23)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.2.1...v0.3.0)

## [v0.2.1](https://github.com/ryancyq/mime_actor/tree/v0.2.1) (2024-06-23)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.2.0...v0.2.1)

## [v0.2.0](https://github.com/ryancyq/mime_actor/tree/v0.2.0) (2024-06-23)

[Full Changelog](https://github.com/ryancyq/mime_actor/compare/v0.1.0...v0.2.0)



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
