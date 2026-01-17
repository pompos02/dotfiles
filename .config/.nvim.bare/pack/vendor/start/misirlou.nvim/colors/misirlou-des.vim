lua << EOF
package.loaded["misirlou.palette"] = nil
require("misirlou-des").colorscheme()
EOF
