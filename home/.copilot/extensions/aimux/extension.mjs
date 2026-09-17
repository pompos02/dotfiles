import { execFile } from "node:child_process";
import { joinSession } from "@github/copilot-sdk/extension";

const session = await joinSession();
const working = () => execFile("aimux", ["set", "working"], () => {});

session.on("permission.completed", working);
session.on("user_input.completed", working);
session.on("elicitation.completed", working);
