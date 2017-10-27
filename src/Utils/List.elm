module Utils.List exposing (..)

import List exposing (..)
import List.Extra exposing (..)

-- Contract: both buckets and xs are sorted according to the relevant criterion.
-- Elements that do not fit into a bucket will be dropped.
-- Elements that fit into more than one bucket will go into the last one.
bucketize_by : (b -> e -> Bool) -> List b -> List e -> List (b, List e)
bucketize_by in_bucket buckets xs =
    case buckets of
        []      -> []
        (b::bs) -> let (here, rest) = span (in_bucket b) xs
                   in (b, here) :: (bucketize_by in_bucket bs rest)
