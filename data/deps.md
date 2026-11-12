# Dependency cache update

## discourse-bundler

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 6.1.0 | 7 | 0 | 4.008 | 3.359 | 3.189 | 540 | 3.148 | 540 | 1177 | 37004 |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | Intel(R) Xeon(R) Processor | 6.1.0 | 1 | 0 | 1.972 | 2.301 | 2.489 | 540 | 2.261 | 541 | 1177 | 37004 |
| actions-cache | depot | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 2.546 | 2.437 | 7.39 | 565 | 2.619 | 566 | 1177 | 37004 |
| actions-cache | depot | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 7 | 0 | 2.574 | 3.143 | 7.473 | 565 | 2.514 | 569 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 8.705 | 4.992 | 6.916 | 565 | 7.961 | 565 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V45 96-Core Processor | 6.1.0 | 1 | 0 | 7.557 | 6.298 | 6.001 | 567 | 5.826 | 565 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 7.993 | 7.171 | 6.245 | 565 | 7.757 | 565 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 3 | 0 | 6.175 | 5.439 | 5.115 | 565 | 6.855 | 565 | 1177 | 37004 |
| actions-cache | github | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | 6.1.0 | 2 | 1 | 5.655 | 5.194 | 4.453 | 565 | 7.623 | 565 | 1177 | 37004 |
| actions-cache | github | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 3 | 0 | 7.993 | 6.298 | 6.245 | 565 | 8.138 | 542 | 1177 | 37004 |
| actions-cache | github | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 6.1.0 | 4 | 0 | 5.915 | 5.317 | 5.041 | 565 | 8.976 | 542 | 1177 | 37004.0 |
| actions-cache | github | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 6.1.0 | 7 | 0 | 8.263 | 3.179 | 3.965 | 543 | 8.685 | 542 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.43.1 | 2 | 0 | 6.896 | 3.286 | 5.026 | 19 | 5.698 | 515 | 1177 | 37004.0 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.45.0 | 1 | 0 | 12.959 | 4.978 | 8.708 | 16 | 8.614 | 515 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.46.0 | 1 | 0 | 18.968 | 2.278 | 5.269 | 16 | 10.25 | 516 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.47.0 | 2 | 0 | 6.063 | 2.438 | 4.113 | 16 | 8.338 | 517 | 1177 | 37004.0 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | AMD EPYC | Intel(R) Xeon(R) Processor | 1.43.2 | 1 | 0 | 6.242 | 3.313 | 4.624 | 16 | 5.598 | 534 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | bab418487a46 | bbb722e4322e | Intel(R) Xeon(R) Processor | AMD EPYC | 1.44.0 | 1 | 0 | 6.861 | 2.159 | 4.872 | 16 | 6.897 | 515 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 6.536 | 5.489 | 3.657 | 16 | 6.091 | 516 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.45.0 | 1 | 0 | 9.39 | 6.199 | 6.266 | 16 | 5.529 | 516 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.46.0 | 1 | 0 | 15.033 | 4.737 | 4.928 | 16 | 6.983 | 515 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.47.0 | 2 | 0 | 11.104 | 6.57 | 7.145 | 16 | 6.143 | 515 | 1177 | 37004.0 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 5.412 | 515 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 6.149 | 516 | 1177 | 37004 |
| boringcache | boringcache | blacksmith 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 6.021 | 515 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 4.016 | 2.679 | 2.866 | 16 | 3.804 | 538 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 4.494 | 2.807 | 3.517 | 26 | 3.748 | 539 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 4.106 | 3.18 | 2.865 | 16 | 3.587 | 540 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 4.281 | 2.595 | 2.557 | 16 | 3.692 | 539 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.45.0 | 1 | 0 | 4.712 | 2.73 | 4.491 | 16 | 4.468 | 538 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.46.0 | 1 | 0 | 5.18 | 3.402 | 2.613 | 16 | 3.678 | 538 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | depot-4 | bab418487a46 | bbb722e4322e | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.47.0 | 2 | 0 | 4.567 | 2.935 | 2.156 | 16 | 4.387 | 538 | 1177 | 37004.0 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 6.536 | 5.489 | 3.657 | 16 | 3.414 | 539 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.45.0 | 1 | 0 | 9.39 | 6.199 | 6.266 | 16 | 4.007 | 538 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.46.0 | 1 | 0 | 15.033 | 4.737 | 4.928 | 16 | 3.411 | 540 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.47.0 | 2 | 0 | 11.104 | 6.57 | 7.145 | 16 | 4.188 | 538 | 1177 | 37004.0 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 4.144 | 537 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 5.788 | 538 | 1177 | 37004 |
| boringcache | boringcache | depot 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 3.668 | 539 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.44.0 | 1 | 0 | 6.536 | 5.489 | 3.657 | 16 | 9.059 | 536 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.45.0 | 1 | 0 | 9.39 | 6.199 | 6.266 | 16 | 8.033 | 536 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.47.0 | 2 | 0 | 11.104 | 6.57 | 7.145 | 16 | 9.514 | 536 | 1177 | 37004.0 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | Intel(R) Xeon(R) 6973P-C | 1.46.0 | 1 | 0 | 15.033 | 4.737 | 4.928 | 16 | 7.586 | 536 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC 9V74 80-Core Processor | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 7.846 | 536 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | INTEL(R) XEON(R) PLATINUM 8573C | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 6.449 | 536 | 1177 | 37004 |
| boringcache | boringcache | github 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC 7763 64-Core Processor | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 7.817 | 536 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 6.536 | 5.489 | 3.657 | 16 | 6.071 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.45.0 | 1 | 0 | 9.39 | 6.199 | 6.266 | 16 | 6.219 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.46.0 | 1 | 0 | 15.033 | 4.737 | 4.928 | 16 | 12.065 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.47.0 | 1 | 0 | 11.859 | 5.199 | 9.075 | 16 | 6.351 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 7.512 | 4.885 | 4.715 | 16 | 5.514 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 8.035 | 4.521 | 5.639 | 16 | 5.777 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | github | bab418487a46 | bbb722e4322e | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC | 1.43.1 | 1 | 0 | 5.932 | 5.035 | 4.313 | 16 | 5.62 | 514 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.43.1 | 2 | 0 | 5.928 | 3.954 | 3.735 | 16 | 5.315 | 515 | 1177 | 37004.0 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 5.856 | 3.657 | 3.603 | 16 | 5.757 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 7.157 | 3.222 | 3.181 | 16 | 5.93 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.45.0 | 1 | 0 | 9.272 | 4.398 | 6.689 | 17 | 6.072 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.46.0 | 1 | 0 | 8.853 | 2.948 | 4.868 | 16 | 7.935 | 515 | 1177 | 37004 |
| boringcache | boringcache | namespace 4c | namespace-4 | bab418487a46 | bbb722e4322e | AMD EPYC | AMD EPYC | 1.47.0 | 1 | 0 | 6.72 | 3.623 | 3.462 | 16 | 6.615 | 515 | 1177 | 37004 |

## mastodon-bundler

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 6.1.0 | 4 | 0 | 1.059 | 2.976 | 1.601 | 82 | 1.345 | 82 | 190 | 19550.0 |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | Intel(R) Xeon(R) Processor | 6.1.0 | 1 | 0 | 0.828 | 2.316 | 1.567 | 82 | 0.803 | 82 | 190 | 19550 |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | Intel(R) Xeon(R) Processor | AMD EPYC | 6.1.0 | 1 | 0 | 0.844 | 1.837 | 1.554 | 82 | 0.827 | 82 | 190 | 19550 |
| actions-cache | depot | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 1.6 | 2.185 | 1.648 | 85 | 1.214 | 85 | 190 | 19550 |
| actions-cache | depot | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 5 | 0 | 1.122 | 2.435 | 1.588 | 85 | 1.105 | 86 | 190 | 19550 |
| actions-cache | github | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 1.788 | 4.208 | 2.523 | 86 | 3.464 | 86 | 190 | 19550 |
| actions-cache | github | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 2 | 0 | 2.741 | 5.256 | 3.281 | 86 | 2.519 | 86 | 190 | 19550.0 |
| actions-cache | github | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | 6.1.0 | 2 | 0 | 2.325 | 5.791 | 3.242 | 86 | 2.205 | 86 | 190 | 19550.0 |
| actions-cache | github | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 1 | - | - | - | - | - | - | - | - |
| actions-cache | github | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 5 | 0 | 2.444 | 4.208 | 3.042 | 86 | 2.105 | 82 | 190 | 19550 |
| actions-cache | github | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 6.1.0 | 5 | 0 | 2.096 | 2.86 | 2.4 | 82 | 2.113 | 82 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 2.884 | 2.502 | 3.857 | 7 | 3.618 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 3.262 | 2.924 | 3.767 | 5 | 3.14 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 3.957 | 2.602 | 3.885 | 5 | 3.46 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.45.0 | 1 | 0 | 5.741 | 2.49 | 3.552 | 5 | 6.254 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.46.0 | 1 | 0 | 4.063 | 2.183 | 3.316 | 5 | 3.704 | 85 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.47.0 | 1 | 0 | 3.872 | 2.824 | 2.925 | 5 | 6.968 | 86 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 3.136 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.45.0 | 1 | 0 | 2.377 | 3.752 | 2.18 | 5 | 3.602 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.47.0 | 1 | 0 | 2.302 | 4.502 | 2.161 | 5 | 7.24 | 86 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | Intel(R) Xeon(R) Processor | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 3.092 | 87 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 3.09 | 3.521 | 2.28 | 5 | 3.518 | 84 | 190 | 19550 |
| boringcache | boringcache | blacksmith 4c | github | 85cc1449181c | bcbf3651da6d | INTEL(R) XEON(R) PLATINUM 8573C | Intel(R) Xeon(R) Processor | 1.46.0 | 1 | 0 | 3.802 | 3.399 | 2.902 | 5 | 6.948 | 87 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 2.144 | 2.315 | 2.317 | 5 | 1.741 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 1.673 | 2.905 | 2.156 | 5 | 1.589 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 1.985 | 2.43 | 1.982 | 5 | 1.59 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.45.0 | 1 | 0 | 1.832 | 2.461 | 2.074 | 5 | 1.61 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.46.0 | 1 | 0 | 1.686 | 2.429 | 1.899 | 5 | 1.52 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | depot-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.47.0 | 1 | 0 | 2.118 | 2.433 | 1.754 | 5 | 1.799 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 1.62 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 1.758 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.45.0 | 1 | 0 | 2.377 | 3.752 | 2.18 | 5 | 1.492 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.47.0 | 1 | 0 | 2.302 | 4.502 | 2.161 | 5 | 2.031 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 3.09 | 3.521 | 2.28 | 5 | 1.571 | 88 | 190 | 19550 |
| boringcache | boringcache | depot 4c | github | 85cc1449181c | bcbf3651da6d | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC 9R45 96-Core Processor | 1.46.0 | 1 | 0 | 3.802 | 3.399 | 2.902 | 5 | 1.38 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 2.485 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V45 96-Core Processor | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 2.501 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | Intel(R) Xeon(R) 6973P-C | 1.45.0 | 1 | 0 | 2.377 | 3.752 | 2.18 | 5 | 3.157 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | Intel(R) Xeon(R) 6973P-C | 1.47.0 | 1 | 0 | 2.302 | 4.502 | 2.161 | 5 | 3.861 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 9V74 80-Core Processor | AMD EPYC 7763 64-Core Processor | 1.44.0 | 1 | 0 | 3.09 | 3.521 | 2.28 | 5 | 2.621 | 88 | 190 | 19550 |
| boringcache | boringcache | github 4c | github | 85cc1449181c | bcbf3651da6d | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC 7763 64-Core Processor | 1.46.0 | 1 | 0 | 3.802 | 3.399 | 2.902 | 5 | 5.779 | 88 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 6.453 | 4.199 | 4.154 | 5 | 3.977 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 4.634 | 4.385 | 3.984 | 5 | 2.561 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.45.0 | 1 | 0 | 2.377 | 3.752 | 2.18 | 5 | 2.618 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | github | 85cc1449181c | bcbf3651da6d | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 3.09 | 3.521 | 2.28 | 5 | 2.619 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | github | 85cc1449181c | bcbf3651da6d | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC | 1.46.0 | 1 | 0 | 3.802 | 3.399 | 2.902 | 5 | 2.672 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 2.814 | 2.854 | 2.798 | 5 | 2.185 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 2.94 | 3.232 | 2.4 | 5 | 2.163 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 2.942 | 3.695 | 2.305 | 5 | 2.157 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.45.0 | 1 | 0 | 3.11 | 2.773 | 2.357 | 5 | 2.951 | 84 | 190 | 19550 |
| boringcache | boringcache | namespace 4c | namespace-4 | 85cc1449181c | bcbf3651da6d | AMD EPYC | AMD EPYC | 1.46.0 | 1 | 0 | 3.358 | 3.326 | 2.322 | 5 | 2.622 | 84 | 190 | 19550 |

## posthog-pnpm

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 6.1.0 | 3 | 0 | 9.579 | 5.612 | 7.011 | 723 | 5.001 | 724 | 2721 | 163161 |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | Intel(R) Xeon(R) Processor | 6.1.0 | 1 | 0 | 6.744 | 3.943 | 5.194 | 723 | 10.531 | 724 | 2721 | 163161 |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | Intel(R) Xeon(R) Processor | AMD EPYC | 6.1.0 | 1 | 0 | 7.555 | 3.286 | 4.965 | 723 | 5.876 | 724 | 2721 | 163161 |
| actions-cache | actions-cache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 5.682 | 3.599 | 12.236 | 750 | 5.824 | 761 | 2721 | 163161 |
| actions-cache | depot | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 11.717 | 7.144 | 10.511 | 759 | 5.68 | 763 | 2721 | 163161 |
| actions-cache | depot | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 4 | 0 | 4.903 | 3.091 | 10.898 | 755 | 5.395 | 759 | 2721 | 163161.0 |
| actions-cache | actions-cache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 18.573 | 21.919 | 8.717 | 757 | 19.995 | 757 | 2721 | 163161 |
| actions-cache | github | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 14.999 | 13.806 | 11.468 | 757 | 13.168 | 752 | 2721 | 163161 |
| actions-cache | github | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 17.173 | 14.167 | 17.298 | 757 | 17.211 | 757 | 2721 | 163161 |
| actions-cache | github | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | 6.1.0 | 1 | 0 | 15.676 | 13.171 | 12.399 | 757 | 13.084 | 757 | 2721 | 163161 |
| actions-cache | github | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V74 80-Core Processor | INTEL(R) XEON(R) PLATINUM 8573C | 6.1.0 | 1 | 0 | 19.955 | 23.758 | 9.123 | 757 | 19.951 | 757 | 2721 | 163161 |
| actions-cache | github | github 4c | github | 5871475311c8 | 41457ecc938b | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 13.342 | 11.155 | 12.052 | 757 | 21.027 | 757 | 2721 | 163161 |
| actions-cache | github | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 3 | 0 | 15.676 | 13.806 | 12.399 | 757 | 18.696 | 726 | 2721 | 163161 |
| actions-cache | github | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 6.1.0 | 1 | 0 | 19.955 | 23.758 | 9.123 | 757 | 21.956 | 726 | 2721 | 163161 |
| actions-cache | github | namespace 4c | github | 5871475311c8 | 41457ecc938b | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | AMD EPYC | 6.1.0 | 1 | 0 | 13.342 | 11.155 | 12.052 | 757 | 21.261 | 726 | 2721 | 163161 |
| actions-cache | actions-cache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 18.612 | 4.992 | 7.441 | 736 | 20.895 | 725 | 2721 | 163161 |
| actions-cache | github | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 6.1.0 | 5 | 0 | 18.73 | 5.685 | 7.529 | 729 | 19.204 | 725 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 10.315 | 3.745 | 9.481 | 72 | 10.024 | 817 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 10.478 | 3.374 | 9.38 | 73 | 9.257 | 815 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 13.976 | 4.134 | 11.761 | 74 | 10.562 | 819 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | Intel(R) Xeon(R) Processor | 1.46.0 | 2 | 1 | 9.339 | 3.483 | 7.419 | 73 | 8.944 | 845 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 10.034 | 816 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 15.508 | 13.695 | 11.575 | 78 | 12.462 | 819 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 19.071 | 16.773 | 9.864 | 76 | 11.317 | 817 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.46.0 | 1 | 0 | 34.442 | 17.42 | 172.848 | 96 | 27.877 | 827 | 2721 | 163161 |
| boringcache | boringcache | blacksmith 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.46.0 | 1 | 0 | 18.911 | 27.572 | 9.189 | 75 | 8.972 | 815 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 | 1.43.1 | 1 | 0 | 12.926 | 3.349 | 6.025 | 76 | 11.532 | 843 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.42.2 | 1 | 0 | 10.06 | 3.274 | 6.539 | 75 | 9.528 | 861 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 8.912 | 3.651 | 7.407 | 76 | 7.087 | 857 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 9.675 | 3.037 | 7.538 | 76 | 7.841 | 862 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | depot-4 | 5871475311c8 | 41457ecc938b | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.46.0 | 2 | 0 | 12.164 | 5.476 | 5.96 | 77 | 7.198 | 862 | 2721 | 163161.0 |
| boringcache | boringcache | depot 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 8.435 | 859 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 15.508 | 13.695 | 11.575 | 78 | 6.293 | 865 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.2 | 1 | 0 | 19.071 | 16.773 | 9.864 | 76 | 7.137 | 857 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.46.0 | 1 | 0 | 34.442 | 17.42 | 172.848 | 96 | 7.154 | 860 | 2721 | 163161 |
| boringcache | boringcache | depot 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.46.0 | 1 | 0 | 18.911 | 27.572 | 9.189 | 75 | 6.94 | 863 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.44.0 | 1 | 0 | 15.508 | 13.695 | 11.575 | 78 | 12.908 | 852 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V74 80-Core Processor | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 17.105 | 849 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC 7763 64-Core Processor | 1.42.2 | 1 | 0 | 19.344 | 17.308 | 8.94 | 76 | 23.707 | 849 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC 7763 64-Core Processor | 1.43.2 | 1 | 0 | 19.071 | 16.773 | 9.864 | 76 | 14.762 | 850 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC 7763 64-Core Processor | 1.46.0 | 1 | 0 | 34.442 | 17.42 | 172.848 | 96 | 16.821 | 850 | 2721 | 163161 |
| boringcache | boringcache | github 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V74 80-Core Processor | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | 1.46.0 | 1 | 0 | 18.911 | 27.572 | 9.189 | 75 | 13.416 | 849 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 14.504 | 13.914 | 9.458 | 76 | 13.319 | 815 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 15.508 | 13.695 | 11.575 | 78 | 12.138 | 818 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.43.2 | 1 | 0 | 19.071 | 16.773 | 9.864 | 76 | 11.335 | 815 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V45 96-Core Processor | AMD EPYC | 1.46.0 | 1 | 0 | 34.442 | 17.42 | 172.848 | 96 | 28.31 | 819 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | github | 5871475311c8 | 41457ecc938b | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.46.0 | 1 | 0 | 18.911 | 27.572 | 9.189 | 75 | 12.187 | 816 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.42.2 | 1 | 0 | 22.116 | 4.877 | 6.772 | 73 | 20.184 | 816 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 10.912 | 4.686 | 6.782 | 72 | 11.851 | 815 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.43.2 | 1 | 0 | 13.419 | 5.691 | 7.66 | 74 | 11.215 | 815 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 12.897 | 4.843 | 18.724 | 78 | 13.887 | 817 | 2721 | 163161 |
| boringcache | boringcache | namespace 4c | namespace-4 | 5871475311c8 | 41457ecc938b | AMD EPYC | AMD EPYC | 1.46.0 | 2 | 1 | 12.623 | 5.412 | 6.777 | 74 | 11.924 | 816 | 2721 | 163161 |

## posthog-uv

| Lane | Cache backend | Runner | Cache from | Before | After | Source CPU | Consumer CPU | Version | Samples | Failed | Restore before s | Install s | Save s | Save network MB | Restore after s | Restore after network MB | Cache MB | Cache files |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 6.1.0 | 3 | 0 | 7.185 | 0.73 | 5.148 | 997 | 8.433 | 999 | 3582 | 66752 |
| actions-cache | blacksmith | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | Intel(R) Xeon(R) Processor | 6.1.0 | 2 | 0 | 8.773 | 0.967 | 6.398 | 997 | 5.608 | 998 | 3582 | 66757.0 |
| actions-cache | actions-cache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 5.804 | 0.82 | 14.111 | 1045 | 6.02 | 1044 | 3582 | 66731 |
| actions-cache | depot | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 1 | 0 | 12.682 | 1.157 | 13.642 | 1036 | 6.553 | 1055 | 3582 | 66733 |
| actions-cache | depot | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 6.1.0 | 4 | 0 | 5.429 | 0.812 | 13.728 | 1039 | 5.92 | 1044 | 3582 | 66757.5 |
| actions-cache | actions-cache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 19.525 | 4.071 | 9.495 | 1043 | 18.249 | 1043 | 3582 | 66731 |
| actions-cache | github | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 6.1.0 | 2 | 0 | 16.77 | 2.638 | 13.742 | 1044 | 14.282 | 1044 | 3582 | 66744.0 |
| actions-cache | github | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC 9V74 80-Core Processor | 6.1.0 | 1 | 0 | 23.808 | 4.3 | 12.74 | 1044 | 16.487 | 1044 | 3582 | 66757 |
| actions-cache | github | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | INTEL(R) XEON(R) PLATINUM 8573C | Intel(R) Xeon(R) 6973P-C | 6.1.0 | 1 | 0 | 21.923 | 3.619 | 11.811 | 1043 | 32.551 | 1043 | 3582 | 66752 |
| actions-cache | github | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | AMD EPYC 7763 64-Core Processor | 6.1.0 | 1 | 0 | 15.428 | 2.218 | 12.53 | 1043 | 14.778 | 1044 | 3582 | 66757 |
| actions-cache | github | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 6.1.0 | 2 | 0 | 16.77 | 2.638 | 13.742 | 1044 | 20.393 | 1001 | 3582 | 66744.0 |
| actions-cache | github | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | INTEL(R) XEON(R) PLATINUM 8573C | AMD EPYC | 6.1.0 | 2 | 0 | 22.865 | 3.96 | 12.276 | 1043 | 18.716 | 1000 | 3582 | 66754.5 |
| actions-cache | github | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | AMD EPYC | 6.1.0 | 1 | 0 | 15.428 | 2.218 | 12.53 | 1043 | 19.948 | 1000 | 3582 | 66757 |
| actions-cache | actions-cache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 6.1.0 | 1 | 0 | 18.78 | 0.91 | 10.218 | 1004 | 20.631 | 1001 | 3582 | 66727 |
| actions-cache | github | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 6.1.0 | 5 | 0 | 18.683 | 0.947 | 7.528 | 1009 | 19.279 | 1000 | 3582 | 66757 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 8.434 | 0.859 | 6.739 | 27 | 11.355 | 1013 | 3582 | 66731 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.43.3 | 1 | 0 | 11.031 | 0.73 | 12.847 | 29 | 11.775 | 1013 | 3582 | 66752 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 10.786 | 1.053 | 8.604 | 31 | 12.951 | 1017 | 3582 | 66757 |
| boringcache | boringcache | blacksmith 4c | blacksmith-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.46.0 | 2 | 0 | 8.667 | 0.785 | 5.934 | 28 | 9.476 | 1011 | 3582 | 66757.0 |
| boringcache | boringcache | blacksmith 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 10.578 | 1012 | 3582 | 66731 |
| boringcache | boringcache | blacksmith 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.3 | 1 | 0 | 14.58 | 2.043 | 11.72 | 27 | 10.237 | 1013 | 3582 | 66752 |
| boringcache | boringcache | blacksmith 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.46.0 | 1 | 0 | 17.434 | 1.825 | 4.629 | 31 | 10.541 | 1013 | 3582 | 66757 |
| boringcache | boringcache | blacksmith 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 17.482 | 4.684 | 9.575 | 38 | 9.68 | 1012 | 3582 | 66757 |
| boringcache | boringcache | blacksmith 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | AMD EPYC | 1.46.0 | 1 | 0 | 17.926 | 1.582 | 7.228 | 32 | 7.832 | 1011 | 3582 | 66757 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 11.734 | 1.167 | 4.7 | 32 | 7.071 | 1067 | 3582 | 66732 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.42.2 | 1 | 0 | 10.917 | 0.793 | 4.419 | 28 | 7.445 | 1063 | 3582 | 66731 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.3 | 1 | 0 | 7.435 | 0.843 | 10.033 | 29 | 6.734 | 1060 | 3582 | 66752 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 6.503 | 0.761 | 3.83 | 33 | 6.016 | 1063 | 3582 | 66757 |
| boringcache | boringcache | depot 4c | depot-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9R45 96-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.46.0 | 2 | 0 | 12.275 | 0.868 | 3.756 | 33 | 8.026 | 1066 | 3582 | 66757.5 |
| boringcache | boringcache | depot 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 | 1.43.3 | 1 | 0 | 14.58 | 2.043 | 11.72 | 27 | 9.346 | 1045 | 3582 | 66752 |
| boringcache | boringcache | depot 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 8.842 | 1061 | 3582 | 66731 |
| boringcache | boringcache | depot 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.46.0 | 1 | 0 | 17.434 | 1.825 | 4.629 | 31 | 19.246 | 1060 | 3582 | 66757 |
| boringcache | boringcache | depot 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9R45 96-Core Processor | 1.44.0 | 1 | 0 | 17.482 | 4.684 | 9.575 | 38 | 6.284 | 1065 | 3582 | 66757 |
| boringcache | boringcache | depot 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | AMD EPYC 9R45 96-Core Processor | 1.46.0 | 1 | 0 | 17.926 | 1.582 | 7.228 | 32 | 6.222 | 1069 | 3582 | 66757 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.43.3 | 1 | 0 | 14.58 | 2.043 | 11.72 | 27 | 12.894 | 1055 | 3582 | 66752 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 7763 64-Core Processor | 1.46.0 | 1 | 0 | 17.434 | 1.825 | 4.629 | 31 | 26.489 | 1053 | 3582 | 66757 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC 9V45 96-Core Processor | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 16.713 | 1053 | 3582 | 66731 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC 9V74 80-Core Processor | 1.44.0 | 1 | 0 | 17.482 | 4.684 | 9.575 | 38 | 21.189 | 1053 | 3582 | 66757 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | Intel(R) Xeon(R) 6973P-C | AMD EPYC 7763 64-Core Processor | 1.42.2 | 1 | 0 | 17.797 | 6.236 | 6.465 | 32 | 17.33 | 1053 | 3582 | 66731 |
| boringcache | boringcache | github 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | AMD EPYC 7763 64-Core Processor | 1.46.0 | 1 | 0 | 17.926 | 1.582 | 7.228 | 32 | 14.063 | 1053 | 3582 | 66757 |
| boringcache | boringcache | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.1 | 1 | 0 | 13.834 | 2.122 | 5.972 | 29 | 11.042 | 1010 | 3582 | 66731 |
| boringcache | boringcache | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.43.3 | 1 | 0 | 14.58 | 2.043 | 11.72 | 27 | 14.579 | 1011 | 3582 | 66752 |
| boringcache | boringcache | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 7763 64-Core Processor | AMD EPYC | 1.46.0 | 1 | 0 | 17.434 | 1.825 | 4.629 | 31 | 11.831 | 1010 | 3582 | 66757 |
| boringcache | boringcache | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC 9V74 80-Core Processor | AMD EPYC | 1.44.0 | 1 | 0 | 17.482 | 4.684 | 9.575 | 38 | 13.755 | 1013 | 3582 | 66757 |
| boringcache | boringcache | namespace 4c | github | 86b8aa0e7fd0 | 582cbcd576b9 | Intel(R) Xeon(R) Platinum 8370C CPU @ 2.80GHz | AMD EPYC | 1.46.0 | 1 | 0 | 17.926 | 1.582 | 7.228 | 32 | 11.286 | 1011 | 3582 | 66757 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.42.2 | 1 | 0 | 18.967 | 0.935 | 4.672 | 33 | 16.456 | 1011 | 3582 | 66731 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.43.1 | 1 | 0 | 11.093 | 0.989 | 4.609 | 29 | 11.018 | 1010 | 3582 | 66731 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.43.3 | 1 | 0 | 13.316 | 1.039 | 12.611 | 36 | 12.319 | 1011 | 3582 | 66752 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.44.0 | 1 | 0 | 12.682 | 1.148 | 4.774 | 29 | 14.775 | 1011 | 3582 | 66757 |
| boringcache | boringcache | namespace 4c | namespace-4 | 86b8aa0e7fd0 | 582cbcd576b9 | AMD EPYC | AMD EPYC | 1.46.0 | 2 | 0 | 12.753 | 1.006 | 4.237 | 30 | 11.252 | 1011 | 3582 | 66757.0 |
