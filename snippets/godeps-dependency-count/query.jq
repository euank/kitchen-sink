# Save the original jq file to search for a single instance of a dep later
. as $godeps |

# Find each unique revision in all of the dependencies. Assume that a git
# revision identifies a dependency.
# This is done because a single dependency might provide multiple packages. The
# packages will be listed multiple times with the same revision.
# It is assumed that two dependencies do not have the same revision, which
# should be true.
[.Deps[].Rev] | unique | .[] as $rev | 

# Loop through each unique revision and create an array of all the packages for
# said revision. Select the shortest one for outputting since that will be
# closest to the package directory.
[ $godeps.Deps[] | select(.Rev == $rev) | .ImportPath] | 
sort_by(length) | first
