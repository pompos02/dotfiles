lua << EOF
package.loaded["misirlou.palette"] = nil
require("misirlou-dragon").colorscheme()
EOF
