#if defined _shqke_util_vector_included
  #endinput
#endif
#define _shqke_util_vector_included

stock void StringToVector(const char[] strIn, float vecOut[3])
{
    int pos = 0;
    
    for (int n = 0; n < 3; n++) {
        pos += StringToFloatEx(strIn[pos], vecOut[n]);
    }
}
