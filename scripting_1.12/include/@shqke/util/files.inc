#if defined _shqke_util_files_included
  #endinput
#endif
#define _shqke_util_files_included

stock bool Util_IsValidPath(const char[] path)
{
    if (path[0] == '\0') {
        return false;
    }
    
    if (path[0] == '/' || path[0] == '\\') {
        // Protect absolute paths
        return false;
    }
    
    bool hadDot = false;
    bool hadBackslash = false;
    
    for (int i = 0; path[i] != '\0'; i++) {
        switch (path[i]) {
            case '.':
            {
                if (hadDot) {
                    // Protect relative paths
                    return false;
                }
                
                hadDot = true;
            }
            case '\\':
            {
                if (hadBackslash) {
                    // Protect network paths
                    return false;
                }
                
                hadBackslash = true;
            }
            case ':', '\n', '\r':
            {
                // Protect absolute paths and disallow invalid symbols
                return false;
            }
            default:
            {
                hadDot = false;
                hadBackslash = false;
            }
        }
    }
    
    return true;
}

stock bool Util_CreateDirHierarchy(const char[] path, int mode)
{
    int pos = 0;
    char dir[PLATFORM_MAX_PATH];

    for (int i = 0; i < sizeof(dir) && path[i] != '\0'; i++) {
        if (path[i] == '/' || path[i] == '\\') {
            pos += strcopy(dir[pos], i + 1 - pos, path[pos]);
            if (DirExists(dir)) {
                continue;
            }
            
            if (!CreateDirectory(dir, mode)) {
                return false;
            }
        }
    }

    return true;
}

stock int Util_DefaultExtension(char[] path, int maxlength, const char[] ext)
{
    int pathlen = strlen(path);
    if (pathlen >= maxlength) {
        pathlen = maxlength - 1;
    }
    
    int extlen = strlen(ext);
    if (pathlen < extlen) {
        // Length sanity check
        return -1;
    }
    
    if (strcmp(path[pathlen - extlen], ext) == 0) {
        // Already have extension
        return 0;
    }
    
    if (maxlength <= pathlen + extlen) {
        // Not enough space to append extension
        return -1;
    }
    
    // Append extension
    return strcopy(path[pathlen], maxlength - pathlen, ext);
}

stock int Util_StripKnownExtension(char[] path, const char[] ext)
{
    int pathlen = strlen(path);
    int pos = pathlen - strlen(ext);
    if (pos < 0) {
        // Length sanity check
        return pathlen;
    }
    
    if (strcmp(path[pos], ext) != 0) {
        // Extension isn't present
        return pathlen;
    }
    
    path[pos] = '\0';
    
    return pos;
}

stock int Util_UnqualifiedFileName(char[] name, int maxlength, const char[] path)
{
    if (path[0] == '\0') {
        name[0] = '\0';
        
        return 0;
    }
    
    int pos = strlen(path);
    while (pos > 0) {
        if (path[pos - 1] == '/' || path[pos - 1] == '\\') {
            break;
        }
        
        pos --;
    }
    
    return strcopy(name, maxlength, path[pos]);
}
