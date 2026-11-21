@routing @car @oneway
Feature: Car - Routes between nearby points with equal rounded weights

    Background:
        Given the profile "car"
        And the node locations
            | node | lon       | lat   |
            | a    | 28.90     | 41    |
            | b    | 28.91     | 41    |
            | c    | 28.92     | 41    |
            | d    | 28.93     | 41    |
            | 1    | 28.914    | 41    |
            | 2    | 28.914002 | 41    |
            | e    | 29.91     | 41    |
            | f    | 29.92     | 41    |
            | g    | 29.92     | 41.01 |
            | h    | 29.91     | 41.01 |
            | 4    | 29.914    | 41    |
            | 5    | 29.914002 | 41    |
            | 6    | 29.91401  | 41    |

    # 1 and 2 are about 0.17 metres apart, so their offsets on bc round to the
    # same weight and the route service does not force a step between them.
    Scenario: Car - Equal rounded weights do not allow travel against a one-way road
        Given the ways
            | nodes | highway     | oneway | side_road |
            | ab    | residential | yes    |           |
            | bc    | residential | yes    | yes       |
            | cd    | residential | yes    |           |

        When I route I should get
            | from | to | route | distance |
            | 1    | 2  | bc,bc | 0.2m     |
            | 2    | 1  |       |          |

    Scenario: Car - Equal rounded weights do not allow travel against a reversed one-way road
        Given the ways
            | nodes | highway     | oneway | side_road |
            | ab    | residential | -1     |           |
            | bc    | residential | -1     | yes       |
            | cd    | residential | -1     |           |

        When I route I should get
            | from | to | route | distance |
            | 2    | 1  | bc,bc | 0.2m     |
            | 1    | 2  |       |          |

    # 6 is about 0.84 metres from 4, far enough for the rounded weights to
    # differ, and already takes the detour.
    Scenario: Car - Nearby points on a one-way loop take the reachable detour
        Given the ways
            | nodes | highway     | oneway | side_road |
            | ef    | residential | yes    | yes       |
            | fg    | residential | yes    |           |
            | gh    | residential | yes    |           |
            | he    | residential | yes    |           |

        When I route I should get
            | from | to | route             | distance    |
            | 4    | 5  | ef,ef             | 0.2m        |
            | 6    | 4  | ef,fg,gh,he,ef,ef | 3900m +- 50 |
            | 5    | 4  | ef,fg,gh,he,ef,ef | 3900m +- 50 |
