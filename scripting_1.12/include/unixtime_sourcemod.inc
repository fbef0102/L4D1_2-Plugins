/*
   Unix Time Conversion
	    by bugsy
	      v0.3
	
	http://forums.alliedmods.net/showthread.php?t=91915
	TimeZone data: http://www.epochconverter.com/epoch/timezones.php    
  
  Ported to Source Mod by Milutinke (ByM)
*/

#if defined _file_unixtime_sourcemod_included
	#endinput
#endif
#define _file_unixtime_sourcemod_included

//============================================================================================
//								Macros
//============================================================================================

// Enumerator causes index out of bounds exception for some strange reason, so I had to change everything to define preprocessor
// Change if you must xD
#define UT_TIMEZONE_SERVER	0
#define UT_TIMEZONE_MIT		1
#define UT_TIMEZONE_HAST	2
#define UT_TIMEZONE_AKST	3
#define UT_TIMEZONE_AKDT	4
#define UT_TIMEZONE_PST		5
#define UT_TIMEZONE_PDT		6
#define UT_TIMEZONE_MST		7
#define UT_TIMEZONE_MDT		8
#define UT_TIMEZONE_CST		9
#define UT_TIMEZONE_CDT		10
#define UT_TIMEZONE_EST		11
#define UT_TIMEZONE_EDT		12
#define UT_TIMEZONE_PRT		13
#define UT_TIMEZONE_CNT		14
#define UT_TIMEZONE_AGT		15
#define UT_TIMEZONE_BET		16
#define UT_TIMEZONE_CAT		17
#define UT_TIMEZONE_UTC		18
#define UT_TIMEZONE_WET		19
#define UT_TIMEZONE_WEST	20
#define UT_TIMEZONE_CET		21
#define UT_TIMEZONE_CEST	22
#define UT_TIMEZONE_EET		23
#define UT_TIMEZONE_EEST	24
#define UT_TIMEZONE_ART		25
#define UT_TIMEZONE_EAT		26
#define UT_TIMEZONE_MET		27
#define UT_TIMEZONE_NET		28
#define UT_TIMEZONE_PLT		29
#define UT_TIMEZONE_IST		30
#define UT_TIMEZONE_BST		31
#define UT_TIMEZONE_ICT		32
#define UT_TIMEZONE_CTT		33
#define UT_TIMEZONE_AWST	34
#define UT_TIMEZONE_JST		35
#define UT_TIMEZONE_ACST	36
#define UT_TIMEZONE_AEST	37
#define UT_TIMEZONE_SST		38
#define UT_TIMEZONE_NZST	39
#define UT_TIMEZONE_NZD		40

//============================================================================================
//								Variables
//============================================================================================
stock const int g_iYearSeconds[ 2 ] = { 
	31536000,	// Normal year
	31622400 	// Leap year
};

stock const int g_iMonthSeconds[ 12 ] = { 
	2678400, 	// January		31 
	2419200, 	// February		28
	2678400, 	// March		31
	2592000, 	// April		30
	2678400, 	// May			31
	2592000, 	// June			30
	2678400, 	// July			31
	2678400, 	// August		31
	2592000, 	// September	30
	2678400, 	// October		31
	2592000, 	// November		30
	2678400  	// December		31
};

stock const int g_iTimeZoneOffset[ ] =  {
	-1,
	-39600,
	-36000,
	-32400,
	-28800,
	-28800,
	-25200,
	-25200,
	-21600,
	-21600,
	-18000,
	-18000,
	-14400,
	-14400,
	-12600,
	-10800,
	-10800,
	-3600,
	0,
	0,
	3600,
	3600,
	7200,
	7200,
	10800,
	7200,
	10800,
	12600,
	14400,
	18000,
	19800,
	21600,
	25200,
	28800,
	28800,
	32400,
	34200,
	36000,
	39600,
	43200,
	46800
};
	
stock int g_iTimeZone;
stock const int g_iDaySeconds = 86400;
stock const int g_iHourSeconds = 3600;
stock const int g_iMinuteSeconds = 60;

//============================================================================================
//							Stocks
//============================================================================================
stock void UnixToTime( int iTimeStamp_, int &iYear, int &iMonth, int &iDay, int &iHour, int &iMinute, int &iSecond, int iTimeZone_ = UT_TIMEZONE_UTC ) {
	int iTemp;
	
	iYear = 1970;
	iMonth = 1;
	iDay = 1;
	iHour = 0;

	if ( iTimeZone_ == UT_TIMEZONE_SERVER )
		iTimeZone_ = GetTimeZone( );
		
	iTimeStamp_ += g_iTimeZoneOffset[ iTimeZone_ ];
	
	while( iTimeStamp_ > 0 ) {
		iTemp = IsLeapYear( iYear );

		if ( ( iTimeStamp_ - g_iYearSeconds[ iTemp ] ) >= 0 ) {
			iTimeStamp_ -= g_iYearSeconds[ iTemp ];
			iYear ++;
		} else {
			break;
		}
	}

	while( iTimeStamp_ > 0 ) {
		iTemp = SecondsInMonth( iYear, iMonth );

		if( ( iTimeStamp_ - iTemp ) >= 0 ) {
			iTimeStamp_ -= iTemp;
			iMonth ++;
		} else {
			break;
		}
	}

	while( iTimeStamp_ > 0 ) {
		if ( ( iTimeStamp_ - g_iDaySeconds ) >= 0 ) {
			iTimeStamp_ -= g_iDaySeconds;
			iDay ++;
		} else {
			break;
		}
	}
	
	while( iTimeStamp_ > 0 ) {
		if( ( iTimeStamp_ - g_iHourSeconds ) >= 0 ) {
			iTimeStamp_ -= g_iHourSeconds;
			iHour ++;
		} else {
			break;
		}
	}
	
	iMinute = ( iTimeStamp_ / 60 );
	iSecond = ( iTimeStamp_ % 60 );
}

stock int TimeToUnix( const int iYear, const int iMonth, const int iDay, const int iHour, const int iMinute, const int iSecond, int iTimeZone = UT_TIMEZONE_UTC ) {
	int iIterator, iTimeStamp;

	for( iIterator = 1970; iIterator < iYear ; iIterator ++ )
		iTimeStamp += g_iYearSeconds[ IsLeapYear( iIterator ) ];

	for( iIterator = 1 ; iIterator < iMonth; iIterator ++ )
		iTimeStamp += SecondsInMonth( iYear , iIterator );

	iTimeStamp += ( ( iDay - 1 ) * g_iDaySeconds );
	iTimeStamp += ( iHour * g_iHourSeconds );
	iTimeStamp += ( iMinute * g_iMinuteSeconds );
	iTimeStamp += iSecond;

	if( iTimeZone == UT_TIMEZONE_SERVER )
		iTimeZone = GetTimeZone( );
		
	return ( iTimeStamp + g_iTimeZoneOffset[ iTimeZone ] );
}

stock int GetTimeZone( ) {
	if( g_iTimeZone )
		return g_iTimeZone;
	
	int iZone, iOffset, iTime, iYear, iMonth, iDay, iHour, iMinute, iSecond;
	
	char szTime[ 64 ];
	FormatTime( szTime, sizeof( szTime ), "%m~%d~%y~%H~%M~%S", GetTime( ) );
	
	char szTimeParts[ 6 ][ 4 ];
	ExplodeString( szTime, "~", szTimeParts, sizeof( szTimeParts ), sizeof( szTimeParts[ ] ) );
	
	iYear = StringToInt( szTimeParts[ 2 ] );
	iMonth = StringToInt( szTimeParts[ 0 ] );
	iDay = StringToInt( szTimeParts[ 1 ] );
	
	iHour = StringToInt( szTimeParts[ 3 ] );
	iMinute = StringToInt( szTimeParts[ 4 ] );
	iSecond = StringToInt( szTimeParts[ 5 ] );
	
	iTime = TimeToUnix( iYear, iMonth, iDay, iHour, iMinute, iSecond, UT_TIMEZONE_UTC );
	iOffset = iTime - GetTime( );
	
	for( iZone = 0 ; iZone < 40; iZone ++ ) {
		if( iOffset == g_iTimeZoneOffset[ iZone ] )
			break;
	}
	
	return ( g_iTimeZone = iZone );
}

stock int SecondsInMonth( const int iYear, const int iMonth ) {
	return ( ( IsLeapYear( iYear ) && ( iMonth == 2 ) ) ? ( g_iMonthSeconds[ iMonth - 1 ] + g_iDaySeconds ) : g_iMonthSeconds[ iMonth - 1 ] );
}

stock int IsLeapYear( const int iYear )  {
	return ( ( ( iYear % 4 ) == 0 ) && ( ( ( iYear % 100 ) != 0) || ( ( iYear % 400 ) == 0 ) ) );
}