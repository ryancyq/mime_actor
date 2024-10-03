# Changelog

All notable changes to this project will be documented in this file. See [conventional commits](https://www.conventionalcommits.org/) for commit guidelines.

---
## [Unreleased](https://github.com/ryancyq/mime_actor/tree/HEAD)

### Tests

- use deprecation assertion method from gem - ([c896fe1](https://github.com/ryancyq/mime_actor/commit/c896fe17a47e059db94f8c2ae0f6a46fb652782b)) - Ryan Chang
- update error message assertion across ruby versions - ([3e12cbd](https://github.com/ryancyq/mime_actor/commit/3e12cbd212d8fb83e8d3f2481b33ffdd3daf935a)) - Ryan Chang

### Lib

- upgrade to ruby 3.3.4 - ([de98bce](https://github.com/ryancyq/mime_actor/commit/de98bce438d65a7973b4ad187cc090626593a5a7)) - Ryan Chang
- update gemfile lock - ([d06496b](https://github.com/ryancyq/mime_actor/commit/d06496b25197f2bffaed6a90f5b6a66d9360bc90)) - Ryan Chang
- install rspec-activesupport - ([4e12218](https://github.com/ryancyq/mime_actor/commit/4e12218d62e88f04455467794915bdc2b12cc750)) - Ryan Chang
- rspec-activesupport ([#73](/issues/73)) - ([8f4ca8b](https://github.com/ryancyq/mime_actor/commit/8f4ca8b31430c33166f3d9a55c8ce3fef8ea4f33)) - Ryan Chang
- relax ruby >= 2.5 and rails >= 6.1 - ([e1c23ba](https://github.com/ryancyq/mime_actor/commit/e1c23bafbc43b90ace7b58ee3a05d46ac3408733)) - Ryan Chang
- relax ruby >= 2.5 and rails >= 6.1 ([#83](/issues/83)) - ([70b4232](https://github.com/ryancyq/mime_actor/commit/70b4232a13512d34b4f161c4ab75e52af45fa14a)) - Ryan Chang

---
## [0.7.2](https://github.com/ryancyq/mime_actor/compare/v0.7.1..v0.7.2) - 2024-08-18

### Bug Fixes

- to proper generated method alias through code generator. - ([df120fb](https://github.com/ryancyq/mime_actor/commit/df120fbeee2f5bbac5d3ea07fb89e1fe91a447d1)) - Ryan Chang

### Documentation

- update CHANGELOG.md - ([c3cd250](https://github.com/ryancyq/mime_actor/commit/c3cd250e56e8ea03cdfb973df019fc359841c77b)) - Ryan Chang

### Lib

- exclude changlog.md from gemspec as changelog generation always happen after gem is published - ([6ac1b82](https://github.com/ryancyq/mime_actor/commit/6ac1b82a238b621953888d62e8a02bf8da055383)) - Ryan Chang

---
## [0.7.1](https://github.com/ryancyq/mime_actor/compare/v0.7.0..v0.7.1) - 2024-07-31

### Documentation

- update github action workflow url - ([5043ae3](https://github.com/ryancyq/mime_actor/commit/5043ae3d8bdfe3907d256c43c7b29e57fbcd3b26)) - Ryan Chang

### Features

- tagged logging ([#66](/issues/66)) - ([e5e8fda](https://github.com/ryancyq/mime_actor/commit/e5e8fdad0ebdcadbc2b081fafaaa874c0cf5c2d3)) - Ryan Chang

### Refactoring

- use heredoc for callback kind template - ([18a9e90](https://github.com/ryancyq/mime_actor/commit/18a9e90c7f13a287eff4f8517cd83ec97529da56)) - Ryan Chang
- use heredoc for action method template - ([e52be70](https://github.com/ryancyq/mime_actor/commit/e52be70e0e300d99e41672e82785170b4a71421a)) - Ryan Chang
- code generator with heredoc ([#65](/issues/65)) - ([67ee9d1](https://github.com/ryancyq/mime_actor/commit/67ee9d1fa8bbbb759561297cb29bbbe0becc4b94)) - Ryan Chang

### Tests

- add tagged logging tests - ([9114824](https://github.com/ryancyq/mime_actor/commit/911482484a90337055d52e36e1178de2087a1d46)) - Ryan Chang

### Lib

- wrap #fill_run_sheet around #cue_actor - ([7f0bcaf](https://github.com/ryancyq/mime_actor/commit/7f0bcaf4212845cd8d267d05cdf7fd125460c691)) - Ryan Chang
- install github_changelog_generator for changelog generation - ([9ce6b13](https://github.com/ryancyq/mime_actor/commit/9ce6b130da9f1635a2f26859793a8ee76f423abd)) - Ryan Chang
- exclude pre-release tags - ([26f324f](https://github.com/ryancyq/mime_actor/commit/26f324fd42b79a4869e7611932688a16f9623061)) - Ryan Chang
- generate changelog.md - ([e055c9f](https://github.com/ryancyq/mime_actor/commit/e055c9f88c0d9f2a66397b3afd47ce17d95748a2)) - Ryan Chang
- include changelog in gemspec - ([f0f5084](https://github.com/ryancyq/mime_actor/commit/f0f50847a1e14bde5a1681f77f52f249753093c1)) - Ryan Chang
- generate CHANGELOG.md ([#67](/issues/67)) - ([ac36d54](https://github.com/ryancyq/mime_actor/commit/ac36d542cfd77eac1aa635e328d9b5aeed7fbf5b)) - Ryan Chang

---
## [0.7.0](https://github.com/ryancyq/mime_actor/compare/v0.6.4..v0.7.0) - 2024-07-30

### Bug Fixes

- add .rspec-status to git ignore - ([28c0a1f](https://github.com/ryancyq/mime_actor/commit/28c0a1f948b3e75a922ebeb8c120d77a89a222eb)) - Ryan Chang
- backport active support logging in 6.X - ([67e75be](https://github.com/ryancyq/mime_actor/commit/67e75bea7bde19d21d2856d4705215f23348cdfa)) - Ryan Chang
- add gem deprecator only for rails >= 7 - ([ac96b59](https://github.com/ryancyq/mime_actor/commit/ac96b591abd62d0251b7d2a1a5fd725474de0d76)) - Ryan Chang
- remove duplicate require in logging - ([5479cfc](https://github.com/ryancyq/mime_actor/commit/5479cfc87b4074d2bf7ec6bf2b5e99ed942607ed)) - Ryan Chang
- change all arg validation presence check to #nil? instead of #present? - ([7d50fdf](https://github.com/ryancyq/mime_actor/commit/7d50fdf736560cc126b1075013e738c34631dd50)) - Ryan Chang
- actions/formats validator to guard against empty enumerable - ([6464654](https://github.com/ryancyq/mime_actor/commit/6464654fa582bcba37072a4f13ab04b7eca072fe)) - Ryan Chang
- action/format validation ([#60](/issues/60)) - ([c8715dc](https://github.com/ryancyq/mime_actor/commit/c8715dcf0d0ac6233bfb8062154c32e611265a95)) - Ryan Chang
- callback chain sequence respect definition ordering ([#63](/issues/63)) - ([17c9fcd](https://github.com/ryancyq/mime_actor/commit/17c9fcd9f3fa9684c1cb22c56ee6e526d407d143)) - Ryan Chang

### Documentation

- use gem name as header - ([50b9f7f](https://github.com/ryancyq/mime_actor/commit/50b9f7f8adb0848ff63f66369b9fafba4596f47b)) - Ryan Chang
- update #act_on_action and #start_scene documentation in code - ([3d7c538](https://github.com/ryancyq/mime_actor/commit/3d7c538973eec8d128f5ca2b6c09ae249b88eb79)) - Ryan Chang
- update run_act_callbacks comment on callback sequence - ([1717469](https://github.com/ryancyq/mime_actor/commit/1717469fe9b851aae6fc40649c22f170ea846ab0)) - Ryan Chang
- update readme and compare with new API - ([d5c6f6c](https://github.com/ryancyq/mime_actor/commit/d5c6f6c6a189a02b2062f817ab402cbbb932ff67)) - Ryan Chang
- replace rails with activesupport and action pack for requirements and bump to 7.0+ - ([bfa73fd](https://github.com/ryancyq/mime_actor/commit/bfa73fdfaed95ea0190d5124f96ac0e6abbff434)) - Ryan Chang

### Features

- #act_on_action to replace #respond_act_to ([#61](/issues/61)) - ([ad482ba](https://github.com/ryancyq/mime_actor/commit/ad482babf1d6790fb439470dfbdaf415b4a9505d)) - Ryan Chang

### Refactoring

- extra respond_to logic into private method - ([123692d](https://github.com/ryancyq/mime_actor/commit/123692d1fee5409dbb96e8412deb1533fa66368b)) - Ryan Chang
- callback generator ([#62](/issues/62)) - ([ff2e93b](https://github.com/ryancyq/mime_actor/commit/ff2e93bd8498a959f9faa1294194e8ab26f55cd2)) - Ryan Chang

### Style

- rubocop autocorrect - ([48cc275](https://github.com/ryancyq/mime_actor/commit/48cc275df72b909da3d843fa6efbb1ac9ea991f2)) - Ryan Chang

### Tests

- configure rspec recommended settings - ([43f106c](https://github.com/ryancyq/mime_actor/commit/43f106cefac30e1fb8bfef5d0def7a43142baa6f)) - Ryan Chang
- railtie load_defaults for current version of rails - ([286e2bc](https://github.com/ryancyq/mime_actor/commit/286e2bc70b4a9ffc3bd2c34fac982a368a61fc50)) - Ryan Chang
- skip rails application deprecation test for rails < 7.0 - ([0738a4b](https://github.com/ryancyq/mime_actor/commit/0738a4b2545e33d94acefbde8a3ca6dde4f867e4)) - Ryan Chang
- update error message after changing to #nil? check - ([93badc2](https://github.com/ryancyq/mime_actor/commit/93badc266cc61280586d05253e9d7d7d5779b1fa)) - Ryan Chang
- update action/format validation error message - ([b2d467b](https://github.com/ryancyq/mime_actor/commit/b2d467ba6aa16ba9e8c79b164bc28f6bc27655a1)) - Ryan Chang
- add rescue error filter nil and empty array test cases - ([c058389](https://github.com/ryancyq/mime_actor/commit/c058389c821f74436d1be84b6bce067039f44b4a)) - Ryan Chang
- replace #respond_act_to with #act_on_action - ([92974bb](https://github.com/ryancyq/mime_actor/commit/92974bb6cd7b13c830e0c8b4a1e17acc183d7164)) - Ryan Chang
- update #respond_act_to test cases - ([56e610b](https://github.com/ryancyq/mime_actor/commit/56e610b954c462dd7dba0f901abbcd2e8f3543d4)) - Ryan Chang
- update #start_scene tests with/without block provided - ([71dbc96](https://github.com/ryancyq/mime_actor/commit/71dbc966f68ee11b81631434d78719f0e59e5943)) - Ryan Chang
- update callback chain with/without format should respect the callback definition ordering - ([680d04a](https://github.com/ryancyq/mime_actor/commit/680d04a38c5a57c3393811454d0f0514fce2ee7b)) - Ryan Chang

### Burn

- deprecate methods - ([4f93c56](https://github.com/ryancyq/mime_actor/commit/4f93c5634e3f9bec18fb37e9652373fc76cd043e)) - Ryan Chang
- #actor_delegator - ([c67043e](https://github.com/ryancyq/mime_actor/commit/c67043e7b2aacf64fa9c254c4480d25feda1b10d)) - Ryan Chang
- #respond_act_to - ([eecd02b](https://github.com/ryancyq/mime_actor/commit/eecd02b82d728f33d02f4b1d40aad9855d11851e)) - Ryan Chang
- action existed error - ([71e359c](https://github.com/ryancyq/mime_actor/commit/71e359cc6bce09240449a4eabc65f832cc9dba16)) - Ryan Chang
- callback kind module_eval - ([2313458](https://github.com/ryancyq/mime_actor/commit/2313458e9cdd85bd49363b28db4b406c6c55165f)) - Ryan Chang

### Lib

- lock active support/action pack to 7.0 major version and move rake as dev dependency - ([5a6d91e](https://github.com/ryancyq/mime_actor/commit/5a6d91e4cc4dcfc8744d963a79c68c33c3086497)) - Ryan Chang
- replace #actor_delegator call with block passed into #start_scene - ([3e5936d](https://github.com/ryancyq/mime_actor/commit/3e5936d03e7fd7c4b82ec84414bdc047640eef41)) - Ryan Chang
- replace #respond_act_to with #act_on_action with ActiveSuport::CodeGenerator for action + format registration - ([a21d356](https://github.com/ryancyq/mime_actor/commit/a21d3560ee1258530764856f47a358ced4fb645f)) - Ryan Chang
- ensure generated action method to check against superclass method and raise ActionNotImplemented error accordingly - ([7e7542b](https://github.com/ryancyq/mime_actor/commit/7e7542b03d6a802464e2997a5e74a76b78e4db68)) - Ryan Chang
- skip cue_actor and log warning message if #respond_to handler is not resolved - ([3f2c862](https://github.com/ryancyq/mime_actor/commit/3f2c86271d69d0b4cadedd2fbc4a7a0167515e62)) - Ryan Chang
- remove active support wrap and blank as we moved from present? to nil? - ([a933f34](https://github.com/ryancyq/mime_actor/commit/a933f34604b7550abf1c0ee84f31fd23f54c34da)) - Ryan Chang
- use active support code generator for callback configuration methods - ([9257522](https://github.com/ryancyq/mime_actor/commit/9257522e822d4a2249a81d79dd40c82b1d208050)) - Ryan Chang
- rename all #before_act #after_act #around_act into #act_before #act_after #act_around - ([740790f](https://github.com/ryancyq/mime_actor/commit/740790fe997f1bd16b6120e32c6480a2720ea983)) - Ryan Chang
- allow action and format matching be done in the same callback chain by storing action/format in internal attribute on the controller - ([b93e88d](https://github.com/ryancyq/mime_actor/commit/b93e88d4fbf7ef5f637dfcb339bbeb11d4078e41)) - Ryan Chang
- avoid wrapping action/format params in ActMatcher to accurately determine filter presence - ([d05ea67](https://github.com/ryancyq/mime_actor/commit/d05ea6776cd964676d891c84bf9f43e16114e075)) - Ryan Chang

---
## [0.6.4.alpha](https://github.com/ryancyq/mime_actor/compare/v0.6.3..v0.6.4.alpha) - 2024-07-25

### Bug Fixes

- simplify error message for callable arg - ([7bb41cc](https://github.com/ryancyq/mime_actor/commit/7bb41ccc6b71ad453df1b6db171214f634331fab)) - Ryan Chang

### Documentation

- add original issue with vanilla rails controller rendering for multiple MIME - ([7295626](https://github.com/ryancyq/mime_actor/commit/72956264d244b2b40935a4ca8cac7cba9a79ad8e)) - Ryan Chang

### Features

- actor delegator ([#57](/issues/57)) - ([cac6562](https://github.com/ryancyq/mime_actor/commit/cac6562fa9f583612acfd699bb6fe0ccf68894be)) - Ryan Chang

### Refactoring

- rename with validator into callable validator for more generic naming - ([81a81d3](https://github.com/ryancyq/mime_actor/commit/81a81d314a5d88ab5eebb1160339710f89743688)) - Ryan Chang
- rename with validator into callable validator ([#54](/issues/54)) - ([2bac018](https://github.com/ryancyq/mime_actor/commit/2bac01819bb252f47205b8fbd8dc32bce6b0f945)) - Ryan Chang

### Tests

- add railtie test with rails as dev/test dependency - ([dfaea64](https://github.com/ryancyq/mime_actor/commit/dfaea6431fe514d45f1572844561a53cafc38e98)) - Ryan Chang
- add tests around actor_delegator use case - ([d1f80c4](https://github.com/ryancyq/mime_actor/commit/d1f80c45265ec8a4fd5103548c8ed60f35703221)) - Ryan Chang
- rename empty block variable name in tests - ([67deb6e](https://github.com/ryancyq/mime_actor/commit/67deb6e5605114a4bbd75fffa82f0a471616c9b8)) - Ryan Chang

### Lib

- extract deprecation into separate file - ([6eebef1](https://github.com/ryancyq/mime_actor/commit/6eebef11d9d2ceddcf53b7e7c0205cf8d600d2f7)) - Ryan Chang
- extract deprecation into separate file ([#55](/issues/55)) - ([e8b3792](https://github.com/ryancyq/mime_actor/commit/e8b379284d1abc536f499d02b8ba4336ac337317)) - Ryan Chang
- add railtie initializers - ([6e1c6bf](https://github.com/ryancyq/mime_actor/commit/6e1c6bf450785486198acb2324614b0d06e954b3)) - Ryan Chang
- add deprecator to railtie - ([238ebc9](https://github.com/ryancyq/mime_actor/commit/238ebc9e10e2690e3edafaf8f348854ad563fce5)) - Ryan Chang
- add railtie for deprecation config ([#56](/issues/56)) - ([17bf3f1](https://github.com/ryancyq/mime_actor/commit/17bf3f1580283c491c448d050fae269f7f500d1a)) - Ryan Chang
- extract actor_name generation into a class level generator for configurable purpose - ([d84a1a2](https://github.com/ryancyq/mime_actor/commit/d84a1a20fd74a62442593d4991d77e53d5421ef7)) - Ryan Chang

---
## [0.6.3](https://github.com/ryancyq/mime_actor/compare/v0.6.3.alpha..v0.6.3) - 2024-07-25

### Bug Fixes

- use controller#action_name ([#52](/issues/52)) - ([47ffee1](https://github.com/ryancyq/mime_actor/commit/47ffee11bb25895c6795d8d70773fc8deb859499)) - Ryan Chang
- validate format arg for #cue_actor ([#53](/issues/53)) - ([48fe4c3](https://github.com/ryancyq/mime_actor/commit/48fe4c3e4fbff7079753d060cc12d68e2a16143e)) - Ryan Chang

### Documentation

- update gem summary - ([5eaad51](https://github.com/ryancyq/mime_actor/commit/5eaad514e3a2fa0ebc8a837d231b59953cdea4f9)) - Ryan Chang
- update README with tested EventsController - ([48ae392](https://github.com/ryancyq/mime_actor/commit/48ae3921c47975302d59420e252876d10b44865d)) - Ryan Chang
- update COMPARE with actor responder API - ([53c0ede](https://github.com/ryancyq/mime_actor/commit/53c0ede5a0172fdd1e6e81bb2674e51d9923d0a1)) - Ryan Chang
- update README and COMPARE - ([4055a3d](https://github.com/ryancyq/mime_actor/commit/4055a3dafdc53ddbe0609f53fed75dc68aedc4a6)) - Ryan Chang
- example controller spec ([#31](/issues/31)) - ([ee81e05](https://github.com/ryancyq/mime_actor/commit/ee81e05f757734d32beb3be62d7211e1b3b79df8)) - Ryan Chang

### Features

- run act callbacks in `cue_actor` to allow callbacks to be rescued - ([04f7cb7](https://github.com/ryancyq/mime_actor/commit/04f7cb7724492fcbf2d1ec8b16dbc2382afca407)) - Ryan Chang
- rescue act callbacks ([#51](/issues/51)) - ([d2c4171](https://github.com/ryancyq/mime_actor/commit/d2c41718c749764852dd589d265a6ae313f6eba1)) - Ryan Chang

### Refactoring

- move logger require into shared context - ([b3d063e](https://github.com/ryancyq/mime_actor/commit/b3d063edced304ef43c8f3f12961922f5c027384)) - Ryan Chang

### Tests

- use actor from shared context instead of metadata - ([a99d59d](https://github.com/ryancyq/mime_actor/commit/a99d59d0f91be0a5bf4d2c4d8e3c6e7fca47e1aa)) - Ryan Chang
- add test around rescue error raised in callbacks - ([0b30cc8](https://github.com/ryancyq/mime_actor/commit/0b30cc8da62974f2d3bcabfe353875754001f9d2)) - Ryan Chang
- update action arg removal for #start_scene #cue_actor - ([6b890c6](https://github.com/ryancyq/mime_actor/commit/6b890c68d0e4b1a76a8a8ccc2d25747066991077)) - Ryan Chang
- add format validation tests for #cue_actor - ([1a49db3](https://github.com/ryancyq/mime_actor/commit/1a49db3937808168e67215545d38062bc88ac437)) - Ryan Chang
- add event controllers tests used in README for usage validation - ([d0512ee](https://github.com/ryancyq/mime_actor/commit/d0512eeb9ab668dbd53caea17651d4c1cfac4cfe)) - Ryan Chang
- move event controller into spec/examples - ([df2b069](https://github.com/ryancyq/mime_actor/commit/df2b069e0b4f352f7cf3a6c480601b4c8794c94a)) - Ryan Chang
- update event controller tests with new mime_actor version - ([a681b58](https://github.com/ryancyq/mime_actor/commit/a681b586483c35eed16e997d1306278de48bf799)) - Ryan Chang

### Lib

- allow actor of any visibility to be called - ([b72cb30](https://github.com/ryancyq/mime_actor/commit/b72cb300229b30dbd903469008886e4385f35c26)) - Ryan Chang
- allow actor of any visibility to be called ([#50](/issues/50)) - ([1f96f76](https://github.com/ryancyq/mime_actor/commit/1f96f76319a81504de55f3934a0783a488c694c3)) - Ryan Chang
- avoid passing action around when running through the flow from #start_scene to #cue_actor - ([83b063c](https://github.com/ryancyq/mime_actor/commit/83b063ccca6fd5fa096bba76a896fb62c9c364c3)) - Ryan Chang
- add format validation for #cue_actor - ([e7409ff](https://github.com/ryancyq/mime_actor/commit/e7409ff015cda61114d94c762dc7d1c7fa172c10)) - Ryan Chang

---
## [0.6.3.alpha](https://github.com/ryancyq/mime_actor/compare/v0.6.2..v0.6.3.alpha) - 2024-07-23

### Bug Fixes

- validator lookup should be targeting public methods - ([e3f3a9b](https://github.com/ryancyq/mime_actor/commit/e3f3a9b9081edb4d41765d7923e0fb6c34c0f205)) - Ryan Chang
- dispatcher usage in cue_actor and rescue_actor - ([c2d5bdf](https://github.com/ryancyq/mime_actor/commit/c2d5bdf3a21d4784cc5e00ca19bb71d5dcd3711b)) - Ryan Chang
- callback configuration loop through formats - ([53248d4](https://github.com/ryancyq/mime_actor/commit/53248d4aac92cc161d8018ac5bcc0ac8ba4b3219)) - Ryan Chang
- support collection argument for  action/format filters in act_callacbks configuration ([#47](/issues/47)) - ([68adddd](https://github.com/ryancyq/mime_actor/commit/68addddca707e708be60b36cfed0ddcbc0759aaf)) - Ryan Chang

### Documentation

- update act callbacks dynamically defined method signatures - ([13a36d1](https://github.com/ryancyq/mime_actor/commit/13a36d1a602801eea00f4f9418a420d59a4f3a31)) - Ryan Chang
- add callback sequence run explanation - ([70965cf](https://github.com/ryancyq/mime_actor/commit/70965cf02f705fc5a825c18bfa0f982b85ce42f3)) - Ryan Chang

### Features

- run act callbacks during `start_scene` ([#49](/issues/49)) - ([816aa2d](https://github.com/ryancyq/mime_actor/commit/816aa2dfb2072f2669108cd94de44dc6a6d00fee)) - Ryan Chang

### Refactoring

- dispatcher callable API ([#45](/issues/45)) - ([3c109b9](https://github.com/ryancyq/mime_actor/commit/3c109b9e5778456fc9eb7cc67c00e0082d6c6edb)) - Ryan Chang
- move action collection vs single action rule into a composed rule in validator - ([0cd9485](https://github.com/ryancyq/mime_actor/commit/0cd9485bf7afa7981e7369c143af1677413e610f)) - Ryan Chang
- move action collection vs single action rule into a composed rule in validator ([#46](/issues/46)) - ([a1ad2b8](https://github.com/ryancyq/mime_actor/commit/a1ad2b872783a88a8479c4c086b9e019cd3f8394)) - Ryan Chang

### Tests

- update deprecation message error message - ([bb5200e](https://github.com/ryancyq/mime_actor/commit/bb5200efb12d45bff9c6ef85fbe2e8e1d2e5a7c3)) - Ryan Chang
- update test description typo - ([e0ba1d7](https://github.com/ryancyq/mime_actor/commit/e0ba1d74aed9f526bb2d8d827e7348aaa59acdf8)) - Ryan Chang
- remove #to_callable and use #call directly - ([7ea9e96](https://github.com/ryancyq/mime_actor/commit/7ea9e966a558817a83f9448fcbeca7efa0835ecb)) - Ryan Chang
- callback action/format filters accept array - ([fda6781](https://github.com/ryancyq/mime_actor/commit/fda67818606eb2dfcf2a77fc95e6fe9573fc1d5f)) - Ryan Chang
- add act callbacks test sequence - ([050f53b](https://github.com/ryancyq/mime_actor/commit/050f53b4ee3ddb06d24330d1558be7eb1353ba6f)) - Ryan Chang
- add example for callback sequence run as test - ([3b449b4](https://github.com/ryancyq/mime_actor/commit/3b449b486bfe3895deb57845bd31ddf521875001)) - Ryan Chang
- add act callbacks test sequence ([#48](/issues/48)) - ([e9b3b70](https://github.com/ryancyq/mime_actor/commit/e9b3b7048ecfd5cbc92129afff9508b2e626451c)) - Ryan Chang
- stub empty block using variable - ([82423f6](https://github.com/ryancyq/mime_actor/commit/82423f60a90eb1ae92fbd3a1ab46fd1c551b152b)) - Ryan Chang
- add test around start_scene which will run the callbacks before calling actor - ([4de6c64](https://github.com/ryancyq/mime_actor/commit/4de6c646ef349f9c7cdf983eae473c8f7fbdc492)) - Ryan Chang

### Lib

- move rescue module to stage - ([93f1f06](https://github.com/ryancyq/mime_actor/commit/93f1f067a153d5f6a2c33b42b9def0e869c0dbfd)) - Ryan Chang
- allow method call and instance excel to be called directly with target - ([fe538b3](https://github.com/ryancyq/mime_actor/commit/fe538b3b526f90b03e1ca73c05b71fc365b5a1ad)) - Ryan Chang
- support action/format collection as filter - ([b2c7e65](https://github.com/ryancyq/mime_actor/commit/b2c7e658b15dca776788726009df1c68e0e9b825)) - Ryan Chang
- wrap cue_actor with run_act_callbacks - ([b9802dd](https://github.com/ryancyq/mime_actor/commit/b9802ddfa329d2eb18c8e9b24e7dab75efd2878e)) - Ryan Chang

---
## [0.6.2](https://github.com/ryancyq/mime_actor/compare/v0.6.1.rc1..v0.6.2) - 2024-07-21

### Bug Fixes

- rename raise_on_missing_actor o raise_on_actor_error - ([03efa26](https://github.com/ryancyq/mime_actor/commit/03efa26a1a5b24c02746d5333ae602c018a1c978)) - Ryan Chang
- dispatcher to throw method name and handle_actor_error to wrap it in error class - ([c0e548c](https://github.com/ryancyq/mime_actor/commit/c0e548c7c70fc16bdb1d24cb9351764d21f15fc2)) - Ryan Chang
- remove action to_sym by default to bubble incorrect arg earlier on - ([48d1412](https://github.com/ryancyq/mime_actor/commit/48d14124f022aa6de0866727e9c6e52c2b34ade6)) - Ryan Chang
- rescue_actor args passing - ([bc397ae](https://github.com/ryancyq/mime_actor/commit/bc397aec61946c9a4d3853764ecf5c90cf5a4cf3)) - Ryan Chang
- hardcode gem version for deprecated methods removal - ([48c59f5](https://github.com/ryancyq/mime_actor/commit/48c59f5267c7e517586709eb5a48e34a692516eb)) - Ryan Chang
- prevent validate! result being returned - ([eead7ab](https://github.com/ryancyq/mime_actor/commit/eead7ab55d3063400a067a423daea2153b574078)) - Ryan Chang
- use non internal method to check if a callback chain of the name has been defined - ([d4a4885](https://github.com/ryancyq/mime_actor/commit/d4a4885893b185b3030dd6de0ba7f66ef829ecd6)) - Ryan Chang
- avoid registering empty block as callback - ([4dc835b](https://github.com/ryancyq/mime_actor/commit/4dc835b4c44eef6db8febd5183302bfecce79fa8)) - Ryan Chang

### Documentation

- update #cue_actor method doc - ([33ff49d](https://github.com/ryancyq/mime_actor/commit/33ff49ddbe25ab7f4ade310f34ca84725b883398)) - Ryan Chang

### Features

- act callbacks ([#42](/issues/42)) - ([7b413a1](https://github.com/ryancyq/mime_actor/commit/7b413a17e149e506abd8d843391054c63d01b366)) - Ryan Chang

### Refactoring

- dispatcher call ([#38](/issues/38)) - ([3871431](https://github.com/ryancyq/mime_actor/commit/3871431585cad6ae40da9e462a30452646f6ea71)) - Ryan Chang
- replace dispatch_act rescue with dispatch_actor rescue ([#39](/issues/39)) - ([697a1e6](https://github.com/ryancyq/mime_actor/commit/697a1e6bcc158218bfa933eafff4aa8b74e72786)) - Ryan Chang

### Tests

- update actor not found error logging - ([b9774be](https://github.com/ryancyq/mime_actor/commit/b9774be2ddbb9369e7d59609282be997e7fce24f)) - Ryan Chang
- add dispatcher tests - ([ddab7ed](https://github.com/ryancyq/mime_actor/commit/ddab7ed36e1b839029813d5d16fa842dbd91df4c)) - Ryan Chang
- update cue actor for Proc - ([737c530](https://github.com/ryancyq/mime_actor/commit/737c530165d935f3557141ac7131026fd2d24c80)) - Ryan Chang
- update logger block var name - ([2ca4760](https://github.com/ryancyq/mime_actor/commit/2ca4760f74b402094865d2e1069c33657615f9e9)) - Ryan Chang
- add rescue actor scenario for cue actor - ([25fe963](https://github.com/ryancyq/mime_actor/commit/25fe96357e024f865712986b881d5f1c19318c97)) - Ryan Chang
- rename existing rescue#rescue_actor tests to class method - ([1b42530](https://github.com/ryancyq/mime_actor/commit/1b425301c0ecb541baf11148fe5c3cad8ca4809f)) - Ryan Chang
- add rescue#rescue_actor test for instance method - ([ad7b306](https://github.com/ryancyq/mime_actor/commit/ad7b30653b807aa100afe4449bc5fd411f5217ad)) - Ryan Chang
- remove extra test coverage on cue_actor in start_scene - ([353d381](https://github.com/ryancyq/mime_actor/commit/353d381918e14fd487b9f14cd1c6040d2e3f48b8)) - Ryan Chang
- add active support deprecation rspec matcher - ([8016f32](https://github.com/ryancyq/mime_actor/commit/8016f3240f765873f15e4a03f3bfc665066d3463)) - Ryan Chang
- add deprecation tests - ([5d9a1c0](https://github.com/ryancyq/mime_actor/commit/5d9a1c0c1fdff2fcde5d8d2d20a7cecb8568b28c)) - Ryan Chang
- callback tests for #before_act - ([17840fc](https://github.com/ryancyq/mime_actor/commit/17840fc65231ee0cb743ac2f232bbd6fe3f6c9b5)) - Ryan Chang
- include klazz variable in shared context - ([d4d1696](https://github.com/ryancyq/mime_actor/commit/d4d169621733252b5e588ad81953e2b3acfb30eb)) - Ryan Chang
- dry up before/after callback tests - ([00d56eb](https://github.com/ryancyq/mime_actor/commit/00d56eb2c08a15fef5fd328edc984c4910559cad)) - Ryan Chang
- add around callback tests - ([999f187](https://github.com/ryancyq/mime_actor/commit/999f18745e00a10c9b3559c3462aa8ebecdc7791)) - Ryan Chang

### Burn

- unused private methods - ([b7529b6](https://github.com/ryancyq/mime_actor/commit/b7529b6a58cc51d34607a1e2936e1d46a6306223)) - Ryan Chang

### Lib

- keep version as string - ([42a8935](https://github.com/ryancyq/mime_actor/commit/42a8935a91a36d008a142ffbbc1a617a84483ec9)) - Ryan Chang
- keep version as string ([#36](/issues/36)) - ([afa6ea4](https://github.com/ryancyq/mime_actor/commit/afa6ea4e29d933eee226b424ca18657f913d0bea)) - Ryan Chang
- add gem deprecation message - ([45f36f0](https://github.com/ryancyq/mime_actor/commit/45f36f014f6724a13b27de38bba996aef9705c98)) - Ryan Chang
- add gem deprecation message ([#37](/issues/37)) - ([7d20468](https://github.com/ryancyq/mime_actor/commit/7d204685f26f6a5a73f2a9da27d92a7930ec1920)) - Ryan Chang
- introduce dispatcher which does not store call context, instead require context upon invocation - ([7dae104](https://github.com/ryancyq/mime_actor/commit/7dae104e847def45eb62ecb2b13108860d9f4836)) - Ryan Chang
- use dispatcher for cue_actor - ([263a9cf](https://github.com/ryancyq/mime_actor/commit/263a9cff62b11f21a5eda97f78dd1593745b11cf)) - Ryan Chang
- add validation to dispatcher params - ([ef4bda6](https://github.com/ryancyq/mime_actor/commit/ef4bda6c75e9344177807dfcdacc4e8de264e685)) - Ryan Chang
- allow cue_actor to config current action + format context - ([888c141](https://github.com/ryancyq/mime_actor/commit/888c141a5c5bfba9ce3140ff9ce60c9ff3c5e325)) - Ryan Chang
- replace dispatch_act with cue_actor directly and call rescue_actor within cue_actor - ([a82a615](https://github.com/ryancyq/mime_actor/commit/a82a6155450b0a64302b544c2e6c91a99a5b6aa2)) - Ryan Chang
- promote instance method rescue_actor to public - ([a88abb3](https://github.com/ryancyq/mime_actor/commit/a88abb332bd30018087ec9b195a73b2edfc4d699)) - Ryan Chang
- instance method rescue_actor to public ([#40](/issues/40)) - ([f2165d9](https://github.com/ryancyq/mime_actor/commit/f2165d997a860f10ef079384774ed40bcb2c4823)) - Ryan Chang
- use active support deprecation instead of gem deprecate in favor of semver over timeline - ([a03fa7f](https://github.com/ryancyq/mime_actor/commit/a03fa7f2583a81ccd5fc7ff9f86a21915e32408c)) - Ryan Chang
- act callbacks - ([c26c874](https://github.com/ryancyq/mime_actor/commit/c26c874beb1a776f4216cceb66ac5ba6b3ac0e21)) - Ryan Chang
- add action and format to callbacks - ([d2c0de6](https://github.com/ryancyq/mime_actor/commit/d2c0de62f1b5dce5c6fde4ed9bce28ce85f26895)) - Ryan Chang
- implement action and format callback chains - ([7e982fc](https://github.com/ryancyq/mime_actor/commit/7e982fc457b0ea8e29f9ca5f5013f8b431cb8786)) - Ryan Chang
- introduce #run_act_callbacks to run :act and :act_<format> chains - ([3a406c3](https://github.com/ryancyq/mime_actor/commit/3a406c30ca01241e6c4471b331a46568925c50b0)) - Ryan Chang
- add action/format filter validation to act callbacks - ([6e14f4b](https://github.com/ryancyq/mime_actor/commit/6e14f4b446e41affcfc0509005bef8c843772f22)) - Ryan Chang

---
## [0.6.1.beta](https://github.com/ryancyq/mime_actor/compare/v0.6.1..v0.6.1.beta) - 2024-07-06

### Bug Fixes

- rename dispatch_cue to dispatch_act and alias the method for compatibility - ([561daa8](https://github.com/ryancyq/mime_actor/commit/561daa8a227361f77a1f85c424ca28b4dad6299d)) - Ryan Chang
- use `#dispatch_act` ([#33](/issues/33)) - ([e56ae67](https://github.com/ryancyq/mime_actor/commit/e56ae67362b4203be6941a9edddbd4ed5ecb60df)) - Ryan Chang
- removed unused require - ([23cc1c6](https://github.com/ryancyq/mime_actor/commit/23cc1c6728d0a492c514e65e3e950affdbf3bc84)) - Ryan Chang
- use module eval inside module - ([13001bd](https://github.com/ryancyq/mime_actor/commit/13001bd18c844bc06623fb09628d981a4ec76097)) - Ryan Chang
- use `module_eval` inside module ([#34](/issues/34)) - ([ef85a57](https://github.com/ryancyq/mime_actor/commit/ef85a57b41a985e5de1268def9c228a5ff2cead2)) - Ryan Chang
- use %r for regex - ([75b4354](https://github.com/ryancyq/mime_actor/commit/75b435428ba66a35ae1c3b7ba6611e8e75c57b46)) - Ryan Chang

### Documentation

- set yard doc format to markdown - ([f3e940f](https://github.com/ryancyq/mime_actor/commit/f3e940f883d243ea606d42cc24c30c07ba11e843)) - Ryan Chang

### Lib

- align rake dependency - ([cc3c51f](https://github.com/ryancyq/mime_actor/commit/cc3c51fa6675efe511efeede52557f5a997812bd)) - Ryan Chang
- update rake version in gemfile lock - ([8f16f8c](https://github.com/ryancyq/mime_actor/commit/8f16f8c60cf9da99012034632aa1fa590e697aae)) - Ryan Chang

---
## [0.6.1](https://github.com/ryancyq/mime_actor/compare/v0.6.0..v0.6.1) - 2024-07-03

### Bug Fixes

- alias act_on_format to respond_act_to - ([df5f212](https://github.com/ryancyq/mime_actor/commit/df5f2122c221660fe7d84c3c24fd2df8c30752e3)) - Ryan Chang
- ensure validation message use #inspect to describe invalid values - ([c1cd365](https://github.com/ryancyq/mime_actor/commit/c1cd365cb5326c8dfa8d3dac41d4485262941b7a)) - Ryan Chang
- ensure validation message use #inspect  ([#22](/issues/22)) - ([024a04d](https://github.com/ryancyq/mime_actor/commit/024a04d7e9c398f5a7b061ae91028e653ed84a71)) - Ryan Chang
- ensure using present? on nil works via active support - ([afe6c72](https://github.com/ryancyq/mime_actor/commit/afe6c72adff633c8fbc0fa175b572932f8a5f23b)) - Ryan Chang
- require active support `nil` class extension ([#23](/issues/23)) - ([c7dcf97](https://github.com/ryancyq/mime_actor/commit/c7dcf97c18f9613b17c19584c0ac3414749775c9)) - Ryan Chang
- switch back to ruby original public + private class methods definitions - ([d1cd88e](https://github.com/ryancyq/mime_actor/commit/d1cd88e8a28f91a38d6b9f5a31efb11bb88998ab)) - Ryan Chang
- switch back to ClassMethods ([#24](/issues/24)) - ([581f42f](https://github.com/ryancyq/mime_actor/commit/581f42f0f2bb1e5ef6270433240af482205fde0e)) - Ryan Chang
- use alias instead of alias_method - ([0d52680](https://github.com/ryancyq/mime_actor/commit/0d5268045945f0f32ead6678a96f902e771ff51f)) - Ryan Chang
- avoid inline access modifier - ([e66cb38](https://github.com/ryancyq/mime_actor/commit/e66cb38e64fb8efc9f6d61e49e81eaac2f3015af)) - Ryan Chang
- rubocop access modifier ([#26](/issues/26)) - ([78d6d54](https://github.com/ryancyq/mime_actor/commit/78d6d54c7e3a98adde919d360061a04e785c9189)) - Ryan Chang
- extract with + block validation from with validator - ([d720b65](https://github.com/ryancyq/mime_actor/commit/d720b656a07ecf8eb5d6738194c70704b83b4534)) - Ryan Chang
- refactor rescuer dispatch to dynamically handle arguments - ([34831a4](https://github.com/ryancyq/mime_actor/commit/34831a45cd53b73cc324faf0fc4d7c45ef02ff35)) - Ryan Chang
- error class message to use inspect - ([991a20f](https://github.com/ryancyq/mime_actor/commit/991a20f87d97b02f9e3e165dc61271767a68bf4e)) - Ryan Chang
- log message with inspect when param is included - ([ab5ff9c](https://github.com/ryancyq/mime_actor/commit/ab5ff9c40f8220c1a789e68d7d8a3e4264edc758)) - Ryan Chang
- error message should use `#inspect` for param ([#27](/issues/27)) - ([3777278](https://github.com/ryancyq/mime_actor/commit/37772786d99ed47f1bc63edc7eb776ba8a8848d3)) - Ryan Chang
- add respond handler registration to scene - ([d4ddc34](https://github.com/ryancyq/mime_actor/commit/d4ddc34318555627d28fb09cbdd4d7e8f8f7a6b0)) - Ryan Chang
- start_scene to pass actor to cue_actor if present, otherwise fallback to action_format - ([80e2983](https://github.com/ryancyq/mime_actor/commit/80e29838f01b52c95ae3a98a9d1d3c66dbb5cd2c)) - Ryan Chang
- cue_actor to work with string/symbol/proc actor - ([e5e8827](https://github.com/ryancyq/mime_actor/commit/e5e88275807603224a5e40ded2f19d46c7cd8314)) - Ryan Chang
- update type check logic to raise TypeError instead - ([b733074](https://github.com/ryancyq/mime_actor/commit/b7330742ebc436e7929a6edd5f6d3dd3f635d8aa)) - Ryan Chang
- update type check logic to raise `TypeError` instead ([#29](/issues/29)) - ([6cb557f](https://github.com/ryancyq/mime_actor/commit/6cb557f82f706426a313b18ecae7925c520a0dfb)) - Ryan Chang
- ensure actor passed to cue_actor is executed within the instance - ([73885f2](https://github.com/ryancyq/mime_actor/commit/73885f2930626b334ec0dc67ac69cc0db5d0dfd5)) - Ryan Chang
- ensure `actor` passed to `#cue_actor` is executed within the instance ([#30](/issues/30)) - ([ae1e420](https://github.com/ryancyq/mime_actor/commit/ae1e420e0d9d1c25774db8607749176cf5daaef8)) - Ryan Chang

### Documentation

- update top level comment for scene - ([dc5f3da](https://github.com/ryancyq/mime_actor/commit/dc5f3dae1039e94b160645c13019ae1324e4b032)) - Ryan Chang
- update repo link - ([ab72a74](https://github.com/ryancyq/mime_actor/commit/ab72a744ff26ad263afce6f3e3eda8b76f4491b6)) - Ryan Chang

### Features

- add respond handler functionality to scene composition - ([08f1c00](https://github.com/ryancyq/mime_actor/commit/08f1c0059553c22a715caa3d92043aea5f210b61)) - Ryan Chang
- actor responder ([#28](/issues/28)) - ([6b2844a](https://github.com/ryancyq/mime_actor/commit/6b2844aa77e1cfea504d7dc242b9a81849231f8d)) - Ryan Chang

### Refactoring

- explicit declare key argument for #act_on_format - ([d638786](https://github.com/ryancyq/mime_actor/commit/d6387861ab8d9de1954a2c5f498d4b4d2fe1f862)) - Ryan Chang
- change act_on_format to respond_act_to - ([e054f76](https://github.com/ryancyq/mime_actor/commit/e054f7697340706167f7836291851ade6bce6eae)) - Ryan Chang
- act_on_format with respond_act_to ([#21](/issues/21)) - ([8aa93da](https://github.com/ryancyq/mime_actor/commit/8aa93da12db830845e54efc7b98387d232aadad2)) - Ryan Chang
- skip validation if block is assigned to with in rescue - ([2e87801](https://github.com/ryancyq/mime_actor/commit/2e8780186166afe6e1a653a740eb4f445ea313e9)) - Ryan Chang
- rescue validation + dispatch ([#25](/issues/25)) - ([24a3593](https://github.com/ryancyq/mime_actor/commit/24a3593994acf308c19f475f4791e57f47235eca)) - Ryan Chang
- remove unused require in spec - ([4ff8dbf](https://github.com/ryancyq/mime_actor/commit/4ff8dbf434e4e318ff20aa2331629440086ec4a7)) - Ryan Chang

### Tests

- add test for different types of actor_rescuer - ([1a607ee](https://github.com/ryancyq/mime_actor/commit/1a607eede3325078795015333a8eebca52fc5d8d)) - Ryan Chang
- add test for rescue with block - ([50c54b1](https://github.com/ryancyq/mime_actor/commit/50c54b196b7c81b913ccff1d0aeb821ae4e5f578)) - Ryan Chang
- add test for finding rescuers for re-raised error - ([20ed68c](https://github.com/ryancyq/mime_actor/commit/20ed68c5d6d34c2eea72aeab518d794cf2df2954)) - Ryan Chang
- add tests for rescuee constantize - ([04bd445](https://github.com/ryancyq/mime_actor/commit/04bd445ca52aef7107c166e22acbcd84bf0aa34c)) - Ryan Chang
- add test when rescuee cannot be constantized - ([1371ad1](https://github.com/ryancyq/mime_actor/commit/1371ad164f8ef578ccd3d0bc575590ca030a7d3d)) - Ryan Chang
- cue_actor with different type of actors - ([2f18f5c](https://github.com/ryancyq/mime_actor/commit/2f18f5c54cb6b19954421708282955984f04cd3b)) - Ryan Chang
- add test for respond_act_to with block - ([397c6ee](https://github.com/ryancyq/mime_actor/commit/397c6eefe2b5c429ef1aafd82181a49994cf76bb)) - Ryan Chang
- update error raised examples with explicit error class/message - ([302f86d](https://github.com/ryancyq/mime_actor/commit/302f86d7699121b78ab06fa82579edcd32e3ab92)) - Ryan Chang
- move simplecov init into support folder - ([3078d6f](https://github.com/ryancyq/mime_actor/commit/3078d6f56ecf4049e877e0d94ce79f44fcc7811b)) - Ryan Chang

---
## [0.6.0](https://github.com/ryancyq/mime_actor/compare/v0.5.4..v0.6.0) - 2024-07-01

### Bug Fixes

- promote act_on_format to the public API, compose_scene remains a private method without args validations - ([652eea0](https://github.com/ryancyq/mime_actor/commit/652eea0fdd63bd855570163fdbf32c0e4ff44aba)) - Ryan Chang
- promote `#act_on_format` to the public API ([#16](/issues/16)) - ([9464236](https://github.com/ryancyq/mime_actor/commit/946423678ed27daacc17bde8b88633fe2083faae)) - Ryan Chang
- rename rescue_actor_from to rescue_act_from to align with act_on_format - ([1748a59](https://github.com/ryancyq/mime_actor/commit/1748a593255f9bb23b733b9d9c935178e1f2e908)) - Ryan Chang
- use `#rescue_act_from` ([#17](/issues/17)) - ([f4e5443](https://github.com/ryancyq/mime_actor/commit/f4e54430eece5ff762773027afd5e0793dbd5a71)) - Ryan Chang
- combine multiple if into a single if statement - ([93cc763](https://github.com/ryancyq/mime_actor/commit/93cc763bfd4b3f874a20e9fcb2a5b6bf7db74f60)) - Ryan Chang
- switch over to active support class methods to allow private class methods - ([8df5c8a](https://github.com/ryancyq/mime_actor/commit/8df5c8ae0e8c1eb966924e6d430fd368f433d6f6)) - Ryan Chang
- switch over to active support class methods ([#19](/issues/19)) - ([ebed5fe](https://github.com/ryancyq/mime_actor/commit/ebed5fe9b0b62a1cf32c5d7dc748525469fc223f)) - Ryan Chang
- use switch case for action args validation - ([af4e8a6](https://github.com/ryancyq/mime_actor/commit/af4e8a69e20406729cbec4a3ca5882f8c1755b3d)) - Ryan Chang
- simplify action and format validation if-else - ([89f8e89](https://github.com/ryancyq/mime_actor/commit/89f8e897ea55796c5bd119065ceafebe13a12545)) - Ryan Chang
- refactor rescue validations ([#20](/issues/20)) - ([afd68ed](https://github.com/ryancyq/mime_actor/commit/afd68ed57a9da12bf5b9a4986094ffe3180d7234)) - Ryan Chang

### Documentation

- update class/method top level comments - ([7486085](https://github.com/ryancyq/mime_actor/commit/748608500bfd551920819702376a14d0dafa86a9)) - Ryan Chang

### Refactoring

- top level comments ([#18](/issues/18)) - ([43dbc7c](https://github.com/ryancyq/mime_actor/commit/43dbc7cd7f111a853a1293ffb4ab480d10015e0a)) - Ryan Chang

### Lib

- add klazz validator - ([71c88dc](https://github.com/ryancyq/mime_actor/commit/71c88dca1aa3c5fb40f9d9e900a57b0572de3f01)) - Ryan Chang

---
## [0.5.4](https://github.com/ryancyq/mime_actor/compare/v0.5.3..v0.5.4) - 2024-06-29

### Bug Fixes

- alias compose_scene with act_on_format - ([2f18d75](https://github.com/ryancyq/mime_actor/commit/2f18d7548222992f5643fd964aaddc57183a7ee2)) - Ryan Chang
- alias compose_scene to act_on_format ([#15](/issues/15)) - ([7f82257](https://github.com/ryancyq/mime_actor/commit/7f8225725e2ffa0974ac5c7b9f6341dc512e8aff)) - Ryan Chang

### Documentation

- update ruby doc comments - ([ffa9c97](https://github.com/ryancyq/mime_actor/commit/ffa9c979f3177366e2d4ba010c337e51327a5fad)) - Ryan Chang
- update comments according to yardoc format - ([4a8a8ef](https://github.com/ryancyq/mime_actor/commit/4a8a8efffe4007d76acc587fb82d1a07d448ba43)) - Ryan Chang
- remove empty spaces - ([a1934f9](https://github.com/ryancyq/mime_actor/commit/a1934f9854a4e63a1a494b4d04c8ab0690529cab)) - Ryan Chang
- update #compose_scene examples with #act_on_format - ([868919e](https://github.com/ryancyq/mime_actor/commit/868919e13195255577ba640b0e87f212897d84e2)) - Ryan Chang

---
## [0.5.3](https://github.com/ryancyq/mime_actor/compare/v0.5.2..v0.5.3) - 2024-06-29

### Documentation

- move COMPARE.md out of lib folder to prevent it being packaged with the library code - ([9ab1d5a](https://github.com/ryancyq/mime_actor/commit/9ab1d5af9003022a091d2c84abbd754518007723)) - Ryan Chang

---
## [0.5.2](https://github.com/ryancyq/mime_actor/compare/v0.5.1..v0.5.2) - 2024-06-29

### Bug Fixes

- ensure block is passed when calling dispatch_cue - ([d4d46df](https://github.com/ryancyq/mime_actor/commit/d4d46dff19cf878fb80c29e1ebbd8f1ea4105b20)) - Ryan Chang
- ensure block is passed when calling dispatch_cue ([#13](/issues/13)) - ([e5e2650](https://github.com/ryancyq/mime_actor/commit/e5e2650efb4a0bb4cecce9698af3109940013c91)) - Ryan Chang

### Documentation

- update gem description - ([c628df6](https://github.com/ryancyq/mime_actor/commit/c628df62f847b6626e411781ede3f9be3a86fc7b)) - Ryan Chang
- update links in README - ([bab263b](https://github.com/ryancyq/mime_actor/commit/bab263b05543789e703c9e416e187ffb062379b3)) - Ryan Chang
- add COMPARE.md to show before/after using MimeActor - ([f73487d](https://github.com/ryancyq/mime_actor/commit/f73487d7ef45041900e24c0631f70265bd8d38f6)) - Ryan Chang
- add rubydoc link in README - ([34c6d2a](https://github.com/ryancyq/mime_actor/commit/34c6d2a4dcdca7f0587511cf1fab45c0220a10c1)) - Ryan Chang
- add rdoc documentation in code - ([2ee6586](https://github.com/ryancyq/mime_actor/commit/2ee6586fe4be0f02faef03fbf8942bc77ba76403)) - Ryan Chang
- update class/methods with rdoc compatible comments ([#14](/issues/14)) - ([d6e875e](https://github.com/ryancyq/mime_actor/commit/d6e875e637afb4f3a59b0d5ef853defb45b1735b)) - Ryan Chang

---
## [0.5.1](https://github.com/ryancyq/mime_actor/compare/v0.4.0..v0.5.1) - 2024-06-28

### Bug Fixes

- refine logging message to be clearer in context - ([863fc6d](https://github.com/ryancyq/mime_actor/commit/863fc6d50aa4550133cedc08961e229db23a9571)) - Ryan Chang
- refine logging message to be clearer in context ([#10](/issues/10)) - ([64aaf6d](https://github.com/ryancyq/mime_actor/commit/64aaf6d6641386239bbfb41e39bda87cd9a0b3d4)) - Ryan Chang

### Documentation

- update readme with features and usage - ([40675ab](https://github.com/ryancyq/mime_actor/commit/40675ab58996c68d47ad4975c2f17a4655ef9c59)) - Ryan Chang
- replace one of the rescue_actor_from with the usual ruby rescue handler for comparison - ([a62b6c8](https://github.com/ryancyq/mime_actor/commit/a62b6c83233ced9092db8fb134fde2fd79b4d385)) - Ryan Chang

### Style

- exclude vendor rubocop config - ([2e2a063](https://github.com/ryancyq/mime_actor/commit/2e2a063857bb69300e632a06cde791120fc33f6a)) - Ryan Chang

### Tests

- fix action module require - ([5809c53](https://github.com/ryancyq/mime_actor/commit/5809c538e8fa8999c7823a8c9ad02eb7c9dbbf11)) - Ryan Chang
- fix mime_actor autoload test - ([18f9da9](https://github.com/ryancyq/mime_actor/commit/18f9da97c5355a8004a8b1aa56ef8af17a646298)) - Ryan Chang
- add test for cue_actor when actor method not defined - ([e0acb94](https://github.com/ryancyq/mime_actor/commit/e0acb942f66f6614340a48a7c56f7a03f1cc7bb3)) - Ryan Chang
- add non class/string error filter to rescue tests - ([56aecf8](https://github.com/ryancyq/mime_actor/commit/56aecf8f32d3bf2e4c5e2522e985e06de08c219d)) - Ryan Chang
- improve coverage ([#6](/issues/6)) - ([ab2decc](https://github.com/ryancyq/mime_actor/commit/ab2decce2ff2a5623e24e7d3a449dfd79f0316e6)) - Ryan Chang
- add tests to logging module - ([6c1f9d6](https://github.com/ryancyq/mime_actor/commit/6c1f9d60f4a61728b7b41a12404b3516f6130385)) - Ryan Chang
- add tests to logging module ([#7](/issues/7)) - ([271db39](https://github.com/ryancyq/mime_actor/commit/271db3997b3b326e6c42709c73f7964a4d32f0bb)) - Ryan Chang
- add tests around rescue handler invocation context - ([3ea7f40](https://github.com/ryancyq/mime_actor/commit/3ea7f403b9c91b8e74668a96a55df2e14c5b9e4e)) - Ryan Chang
- add tests around rescue handler invocation context ([#8](/issues/8)) - ([6f26124](https://github.com/ryancyq/mime_actor/commit/6f26124417f0e8607369618f91b66b15a115db02)) - Ryan Chang
- add tests for different type of error class - ([5603f81](https://github.com/ryancyq/mime_actor/commit/5603f8199cf7bc7fc6d559266bbd52a919284b9e)) - Ryan Chang
- add tests for different type of error class ([#9](/issues/9)) - ([981c3cc](https://github.com/ryancyq/mime_actor/commit/981c3cc6820877dc81d667435ffc4123d9c3ae77)) - Ryan Chang
- add action controller specific test - ([dff85ea](https://github.com/ryancyq/mime_actor/commit/dff85ea808278b5b755417c803c871f588c60f03)) - Ryan Chang
- add action controller specific test ([#11](/issues/11)) - ([d09642c](https://github.com/ryancyq/mime_actor/commit/d09642cb3fc48cd267b23941bbc88809be421fd7)) - Ryan Chang

### Lib

- rename Act to Action - ([93143ff](https://github.com/ryancyq/mime_actor/commit/93143ff389887186c7f1a0d8e646d0e9e43260e2)) - Ryan Chang

---
## [0.4.0](https://github.com/ryancyq/mime_actor/compare/v0.3.3..v0.4.0) - 2024-06-27

### Bug Fixes

- move visited error check to beginning of the method - ([ca6df5f](https://github.com/ryancyq/mime_actor/commit/ca6df5f6dba88f62a8d14a3eff139d8e9ab396b2)) - Ryan Chang
- encapsulate mime type into stage_formats - ([4003ace](https://github.com/ryancyq/mime_actor/commit/4003ace26f43f839798f83d87a3daf78ef417fe5)) - Ryan Chang
- simplify format invalid error message - ([343e54d](https://github.com/ryancyq/mime_actor/commit/343e54d648b7553b94e6019fa61c330742742f25)) - Ryan Chang
- action filter validation with array of string - ([2203b89](https://github.com/ryancyq/mime_actor/commit/2203b89064281b4e6d99fa70725d8baccc904769)) - Ryan Chang
- simplify acting_scenes with plain hash - ([ee35e10](https://github.com/ryancyq/mime_actor/commit/ee35e10594a80e2ef5bd29e1560e8821f90cbfde)) - Ryan Chang
- update action validation during scene composition - ([cc06c96](https://github.com/ryancyq/mime_actor/commit/cc06c961af94778045d41545db631c5edf58252e)) - Ryan Chang
- update action validation error - ([155611c](https://github.com/ryancyq/mime_actor/commit/155611c086c7efe0ded404f0b0420acfa2097564)) - Ryan Chang
- error class indentation - ([cfe7533](https://github.com/ryancyq/mime_actor/commit/cfe7533e4cc2fd659e26f8704364202f726c0295)) - Ryan Chang
- shift the order of action, format validation in rescue - ([7b3dcfd](https://github.com/ryancyq/mime_actor/commit/7b3dcfdd72d79fe90e874b6c86492c62863759f3)) - Ryan Chang
- remove stage_format in Scene as it has moved to Validator - ([17078a0](https://github.com/ryancyq/mime_actor/commit/17078a075c160a7f0be4308d358a0556b331d42d)) - Ryan Chang
- use default argument for logger - ([8d7b084](https://github.com/ryancyq/mime_actor/commit/8d7b08411dc2ab69d3d796ba8f6e7d7529058916)) - Ryan Chang
- action defined check in scene to include public and private methods - ([2bd1663](https://github.com/ryancyq/mime_actor/commit/2bd166388b68b6496f0acd9068038d3dae918bfc)) - Ryan Chang
- replace #find_actor with #cue_actor and allow #dispatch_cue to wrap the #cue_actor with rescue block - ([760ba15](https://github.com/ryancyq/mime_actor/commit/760ba156a10dc0367d73c528d221fc9a984f46b3)) - Ryan Chang
- remove instance #actor? method in favor of class#actor? - ([17793e6](https://github.com/ryancyq/mime_actor/commit/17793e6ddc7b822ee8f0af5e41ec3dd09f7f86dd)) - Ryan Chang
- scene action defined always check on public + private instance methods - ([f62a613](https://github.com/ryancyq/mime_actor/commit/f62a613989b4d373b16bf0f1f3ba788179f11dcf)) - Ryan Chang

### Tests

- refactor act test scenario - ([907e791](https://github.com/ryancyq/mime_actor/commit/907e791f7ed5d3c5d1f064a730fbeba688b7d1d5)) - Ryan Chang
- refactor rescue test scenario - ([78fea0d](https://github.com/ryancyq/mime_actor/commit/78fea0d43b24938a2c4d9b7bc392b79ca3bbe1ec)) - Ryan Chang
- correct syntax error for rescue - ([f488325](https://github.com/ryancyq/mime_actor/commit/f488325417c307f92fd586949013b5dd87822599)) - Ryan Chang
- clean up rspec context with describe - ([516a3ca](https://github.com/ryancyq/mime_actor/commit/516a3ca838cca23efabba22e589f3606d819f58f)) - Ryan Chang
- update scene test scenario - ([b5a4a84](https://github.com/ryancyq/mime_actor/commit/b5a4a84bdf0e64f21a81c10bdf85f3e9375ad2d4)) - Ryan Chang
- update context naming according to rspec cops - ([59666df](https://github.com/ryancyq/mime_actor/commit/59666df958815ec6fbca8c80315b424af8a5d46f)) - Ryan Chang
- combine accept and reject shared example via acceptance key argument - ([cf684c7](https://github.com/ryancyq/mime_actor/commit/cf684c757ed15fd5f9826c4c26a57851d038092f)) - Ryan Chang
- update mime actor autoload test - ([71b114d](https://github.com/ryancyq/mime_actor/commit/71b114de6bf3f993c034220d64426811014074ff)) - Ryan Chang
- stub logger in test - ([70f7d42](https://github.com/ryancyq/mime_actor/commit/70f7d420673dceef07ee9737e5591e65c4c02a59)) - Ryan Chang
- clean up actie support onload test - ([a61cd8b](https://github.com/ryancyq/mime_actor/commit/a61cd8b4d37b648613962f2f4e3f23a138a6b915)) - Ryan Chang

### Lib

- extract action, format, with validations into validator module - ([30ccc6a](https://github.com/ryancyq/mime_actor/commit/30ccc6af77b76e5534d9200b32634bc61b978add)) - Ryan Chang
- use action, format validators in scene - ([b386ecc](https://github.com/ryancyq/mime_actor/commit/b386ecca8c9ca0e06508a28f59630ea7784ff9a1)) - Ryan Chang
- auto validator in MimeActor module - ([6d815f3](https://github.com/ryancyq/mime_actor/commit/6d815f3e2c641a14bf96216ea58a058612922d54)) - Ryan Chang
- introduce logging module - ([523e4c6](https://github.com/ryancyq/mime_actor/commit/523e4c6dcfe834a083de612cb6ed5e1a91838369)) - Ryan Chang
- additional require for active support logger - ([0c101bd](https://github.com/ryancyq/mime_actor/commit/0c101bd5875465800ddcf4155ce6d3022d4dddab)) - Ryan Chang
- add active support lazy load hooks - ([7c00d6a](https://github.com/ryancyq/mime_actor/commit/7c00d6a09f053d08b8c6d07d251cee5550c70872)) - Ryan Chang

---
## [0.3.3](https://github.com/ryancyq/mime_actor/compare/v0.3.2..v0.3.3) - 2024-06-24

### Bug Fixes

- explicitly require set for ruby 3.1 - ([788293d](https://github.com/ryancyq/mime_actor/commit/788293d4d3ecf9e2fc873f81f1d1aa4d6862d083)) - Ryan Chang

---
## [0.3.2](https://github.com/ryancyq/mime_actor/compare/v0.3.1..v0.3.2) - 2024-06-24

### Lib

- enable mfa in gemspec - ([c73b91a](https://github.com/ryancyq/mime_actor/commit/c73b91a5ea41a7eb439d7687e3e532259edb3e1d)) - Ryan Chang

---
## [0.3.0](https://github.com/ryancyq/mime_actor/compare/v0.2.1..v0.3.0) - 2024-06-23

### Bug Fixes

- remove required relative to allow spec to require granular dependency - ([8beedef](https://github.com/ryancyq/mime_actor/commit/8beedefdc63164e92e7aaa6a026a5fb09778e6f2)) - Ryan Chang

### Lib

- intro MimeActor::Stage to handle actor related logic - ([70fa9d2](https://github.com/ryancyq/mime_actor/commit/70fa9d2c5100bfef4c9d78a15543ccbcd66b76eb)) - Ryan Chang
- separate actor lookup and actor method lookup - ([0750027](https://github.com/ryancyq/mime_actor/commit/0750027e6a4159a7e932bc432faf2849b82b0359)) - Ryan Chang
- use MimeActor:Stage in MimeActor::Scene for actor lookup - ([21ddbd4](https://github.com/ryancyq/mime_actor/commit/21ddbd40049f5b65c79bdfec513aa381df503c9e)) - Ryan Chang
- intro Stage#cue_actor to safely invoke method if defined - ([39041c0](https://github.com/ryancyq/mime_actor/commit/39041c0c44f002155799a00ba472bc27db48cede)) - Ryan Chang
- update rubcop config - ([b8f2e7f](https://github.com/ryancyq/mime_actor/commit/b8f2e7faacb1f111baee2d76bfd20c49a21f259f)) - Ryan Chang

---
## [0.2.1](https://github.com/ryancyq/mime_actor/compare/v0.2.0..v0.2.1) - 2024-06-23

### Bug Fixes

- handle method definition when action name is new - ([53c4e6b](https://github.com/ryancyq/mime_actor/commit/53c4e6b7afb83789b302288f7fcee342ceab71dd)) - Ryan Chang

---
## [0.2.0](https://github.com/ryancyq/mime_actor/compare/v0.1.0..v0.2.0) - 2024-06-23

### Bug Fixes

- update MimeActor::Scene to be responsible only for acting_scenes config - ([06cd112](https://github.com/ryancyq/mime_actor/commit/06cd112b802f2b1eac9ad41e3e6b688c6af03836)) - Ryan Chang
- update MimeActor::Rescuer to be responsible only for actor_rescuer config and rescue_actor for given error - ([e80ecb2](https://github.com/ryancyq/mime_actor/commit/e80ecb26f272ee38b827c2eb8146833e5960107b)) - Ryan Chang
- update MimeActor:Act to be responsible of integrating Scene and Rescuer - ([c35a6cb](https://github.com/ryancyq/mime_actor/commit/c35a6cbdbdaf1aec7a0665ffb4f9326816fe4862)) - Ryan Chang

### Tests

- fix MimeActor:Act name in test - ([5e33ba7](https://github.com/ryancyq/mime_actor/commit/5e33ba795ea75ccf5f4184ec8e740685892ffc5a)) - Ryan Chang

### Lib

- change MimeActor module to be responsible of autoload other modules - ([98e198f](https://github.com/ryancyq/mime_actor/commit/98e198fbd186d016858ec6737a1417a0b9f01c19)) - Ryan Chang
- make MimeActor::Set the default module to use - ([66c0636](https://github.com/ryancyq/mime_actor/commit/66c0636fefa104dd31d7bc60eeb2416898379820)) - Ryan Chang
- rename Formatter to Scene - ([8b9eddb](https://github.com/ryancyq/mime_actor/commit/8b9eddbb17fad3206404d4817374f7967b187b0a)) - Ryan Chang
- change Set to Act - ([199131f](https://github.com/ryancyq/mime_actor/commit/199131f9b449274ea17ad073addb887392ec1a2e)) - Ryan Chang
- change Rescuer to Rescue - ([e2c1b0e](https://github.com/ryancyq/mime_actor/commit/e2c1b0eff941b27a64aada6d6c9813a02e5efded)) - Ryan Chang

<!-- generated by git-cliff -->
