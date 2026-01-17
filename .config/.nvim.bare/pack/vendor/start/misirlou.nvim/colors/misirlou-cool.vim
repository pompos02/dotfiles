lua << EOF
package.loaded["misirlou.palette"] = nil
require("misirlou-cool").colorscheme()
EOF
