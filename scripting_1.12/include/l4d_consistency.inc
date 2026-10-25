#if defined _l4d_consistency_included
 #endinput
#endif
#define _l4d_consistency_included

/**
 * Mark a file for consistency checking, so a client whose copy differs is
 * disconnected by the engine.
 *
 * Wraps IVEngineServer::ForceExactFile, which L4D1's engine implements and its
 * game DLL never calls. See consistency/README.md.
 *
 * Must be called AFTER the file is precached: the engine's own comment on the
 * interface says so, and a path forced before precache may simply be ignored.
 *
 * @param path  Game-relative path, e.g. "models/infected/hunter.mdl".
 * @return      1 when the call was made, 0 when the path was refused (empty).
 * @error       The engine interface is unavailable.
 */
native int ForceExactFile(const char[] path);

public Extension __ext_l4d_consistency =
{
	name = "L4D1 File Consistency",
	file = "l4d_consistency.ext",
	autoload = 1,
	required = 1,
};
