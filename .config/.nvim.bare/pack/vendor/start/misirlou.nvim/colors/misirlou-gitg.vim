lua << EOF
package.loaded["misirlou.palette"] = nil
require("misirlou-gitg").colorscheme()
EOF
