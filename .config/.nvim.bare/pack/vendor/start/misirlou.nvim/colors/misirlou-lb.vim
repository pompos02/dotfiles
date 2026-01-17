lua << EOF
package.loaded["misirlou.palette"] = nil
require("misirlou-lb").colorscheme()
EOF
