# Dependency cache update

## discourse-bundler

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 6.1.0 | 3 | 0 | 4.59 | 3.371 | 3.313 | 540 | 4.082 | 541 | 1177 | 37004 |
| actions-cache | depot | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 2.546 | 2.437 | 7.39 | 565 | 2.619 | 566 | 1177 | 37004 |
| actions-cache | depot | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 2 | 0 | 2.713 | 5.394 | 7.605 | 563 | 2.544 | 568 | 1177 | 37004.0 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V45 96-Core Processor | 6.1.0 | 1 | 0 | 7.557 | 6.298 | 6.001 | 567 | 5.826 | 565 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 7.993 | 7.171 | 6.245 | 565 | 7.757 | 565 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | 6.1.0 | 1 | 0 | 5.655 | 5.194 | 4.453 | 565 | 7.623 | 565 | 1177 | 37004 |
| actions-cache | github | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 2 | 0 | 7.775 | 6.735 | 6.123 | 566 | 8.217 | 542 | 1177 | 37004.0 |
| actions-cache | github | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 6.1.0 | 1 | 0 | 5.655 | 5.194 | 4.453 | 565 | 9.043 | 542 | 1177 | 37004 |
| actions-cache | github | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 6.1.0 | 3 | 0 | 8.263 | 3.198 | 3.637 | 550 | 8.679 | 542 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.43.1 | 2 | 0 | 6.896 | 3.286 | 5.026 | 19 | 5.698 | 515 | 1177 | 37004.0 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | Intel(R) Xeon(R) Processor | 1.43.2 | 1 | 0 | 6.242 | 3.313 | 4.624 | 16 | 5.598 | 534 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 5.412 | 515 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 6.149 | 516 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 6.021 | 515 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 4.016 | 2.679 | 2.866 | 16 | 3.804 | 538 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 4.494 | 2.807 | 3.517 | 26 | 3.748 | 539 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 4.106 | 3.18 | 2.865 | 16 | 3.587 | 540 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 4.144 | 537 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 5.788 | 538 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 3.668 | 539 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC 9V74 80-Core Processor | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 7.846 | 536 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | INTEL(R) XEON(R) PLATINUM 8573C | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 6.449 | 536 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC 7763 64-Core Processor | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 7.817 | 536 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 5.514 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 5.777 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 5.62 | 514 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.43.1 | 2 | 0 | 5.928 | 3.954 | 3.735 | 16 | 5.315 | 515 | 1177 | 37004.0 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 5.856 | 3.657 | 3.603 | 16 | 5.757 | 515 | 1177 | 37004 |

## mastodon-bundler

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 6.1.0 | 2 | 0 | 1.059 | 2.836 | 1.651 | 82 | 1.534 | 82 | 190 | 19550.0 |
| actions-cache | depot | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 1.6 | 2.185 | 1.648 | 85 | 1.214 | 85 | 190 | 19550 |
| actions-cache | depot | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 1.19 | 2.368 | 1.698 | 85 | 1.177 | 86 | 190 | 19550 |
| actions-cache | github | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 2 | 0 | 2.741 | 5.256 | 3.281 | 86 | 2.519 | 86 | 190 | 19550.0 |
| actions-cache | github | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 2 | 0 | 2.741 | 5.256 | 3.281 | 86 | 1.984 | 82 | 190 | 19550.0 |
| actions-cache | github | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 6.1.0 | 2 | 0 | 1.95 | 2.565 | 2.111 | 82 | 2.256 | 82 | 190 | 19550.0 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 2.884 | 2.502 | 3.857 | 7 | 3.618 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 3.262 | 2.924 | 3.767 | 5 | 3.14 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 3.136 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | Intel(R) Xeon(R) Processor | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 3.092 | 87 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 2.144 | 2.315 | 2.317 | 5 | 1.741 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 1.673 | 2.905 | 2.156 | 5 | 1.589 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 1.62 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 1.758 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 2.485 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V45 96-Core Processor | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 2.501 | 88 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 3.977 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 2.561 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 2.814 | 2.854 | 2.798 | 5 | 2.185 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 2.94 | 3.232 | 2.4 | 5 | 2.163 | 84 | 190 | 19550 |

## posthog-pnpm

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 9.579 | 5.612 | 7.011 | 723 | 15.485 | 725 | 2721 | 163161 |
| actions-cache | actions-cache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 5.682 | 3.599 | 12.236 | 750 | 5.824 | 761 | 2721 | 163161 |
| actions-cache | depot | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 11.717 | 7.144 | 10.511 | 759 | 5.68 | 763 | 2721 | 163161 |
| actions-cache | actions-cache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 18.573 | 21.919 | 8.717 | 757 | 19.995 | 757 | 2721 | 163161 |
| actions-cache | github | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 17.173 | 14.167 | 17.298 | 757 | 17.211 | 757 | 2721 | 163161 |
| actions-cache | github | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 1 | 0 | 17.173 | 14.167 | 17.298 | 757 | 20.116 | 726 | 2721 | 163161 |
| actions-cache | actions-cache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 18.612 | 4.992 | 7.441 | 736 | 20.895 | 725 | 2721 | 163161 |
| actions-cache | github | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 19.734 | 5.685 | 7.363 | 727 | 18.725 | 725 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 10.315 | 3.745 | 9.481 | 72 | 10.024 | 817 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 10.034 | 816 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 | 1.43.1 | 1 | 0 | 12.926 | 3.349 | 6.025 | 76 | 11.532 | 843 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.42.2 | 1 | 0 | 10.06 | 3.274 | 6.539 | 75 | 9.528 | 861 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 8.435 | 859 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 17.105 | 849 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC 7763 64-Core Processor | 1.42.2 | 1 | 0 | 19.344 | 17.308 | 8.94 | 76 | 23.707 | 849 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 13.319 | 815 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.42.2 | 1 | 0 | 22.116 | 4.877 | 6.772 | 73 | 20.184 | 816 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 10.912 | 4.686 | 6.782 | 72 | 11.851 | 815 | 2721 | 163161 |

## posthog-uv

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 7.185 | 0.691 | 5.148 | 997 | 8.544 | 999 | 3582 | 66731 |
| actions-cache | actions-cache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 5.804 | 0.82 | 14.111 | 1045 | 6.02 | 1044 | 3582 | 66731 |
| actions-cache | depot | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 12.682 | 1.157 | 13.642 | 1036 | 6.553 | 1055 | 3582 | 66733 |
| actions-cache | actions-cache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 19.525 | 4.071 | 9.495 | 1043 | 18.249 | 1043 | 3582 | 66731 |
| actions-cache | github | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 19.841 | 3.265 | 14.706 | 1043 | 14.784 | 1044 | 3582 | 66731 |
| actions-cache | github | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 1 | 0 | 19.841 | 3.265 | 14.706 | 1043 | 20.137 | 1001 | 3582 | 66731 |
| actions-cache | actions-cache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 18.78 | 0.91 | 10.218 | 1004 | 20.631 | 1001 | 3582 | 66727 |
| actions-cache | github | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 19.234 | 0.947 | 7.13 | 1014 | 19.929 | 1001 | 3582 | 66731 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 8.434 | 0.859 | 6.739 | 27 | 11.355 | 1013 | 3582 | 66731 |
| boringcache | boringcache | blacksmith 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 10.578 | 1012 | 3582 | 66731 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 11.734 | 1.167 | 4.7 | 32 | 7.071 | 1067 | 3582 | 66732 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.42.2 | 1 | 0 | 10.917 | 0.793 | 4.419 | 28 | 7.445 | 1063 | 3582 | 66731 |
| boringcache | boringcache | depot 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 8.842 | 1061 | 3582 | 66731 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V45 96-Core Processor | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 16.713 | 1053 | 3582 | 66731 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | Intel(R) Xeon(R) 6973P-C | AMD EPYC 7763 64-Core Processor | 1.42.2 | 1 | 0 | 17.797 | 6.236 | 6.465 | 32 | 17.33 | 1053 | 3582 | 66731 |
| boringcache | boringcache | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 11.042 | 1010 | 3582 | 66731 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.42.2 | 1 | 0 | 18.967 | 0.935 | 4.672 | 33 | 16.456 | 1011 | 3582 | 66731 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 11.093 | 0.989 | 4.609 | 29 | 11.018 | 1010 | 3582 | 66731 |
