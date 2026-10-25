#if defined _l4d2_nativevote_included
 #endinput
#endif
#define _l4d2_nativevote_included

enum VoteAction
{
	VoteAction_Start,		// param1 = initiator
	VoteAction_PlayerVoted,	// param1 = client, param2 = VOTE_YES Or VOTE_NO
	VoteAction_End,			// param1 = reason
};

enum 
{
	VOTE_YES = 1,
	VOTE_NO = 2,
};

// VoteAction_End reason
enum 
{
	VOTEEND_FULLVOTED = 1,	// All players have voted
	VOTEEND_TIMEEND = 2,	// Time to vote ends
};

/**
 * Return Whether to allow new vote.
 *
 * @return					True is allow, false otherwise.
 */
native bool L4D2NativeVote_IsAllowNewVote();

/**
 * Called when a VoteAction is completed.
 *
 * @param vote              The vote being acted upon.
 * @param action            The action of the vote.
 * @param param1            First action parameter.
 * @param param2            Second action parameter.
 */
typedef L4D2VoteHandler = function void (L4D2NativeVote vote, VoteAction action, int param1, int param2);


methodmap L4D2NativeVote 
{
	// Creates a new NativeVote.
	// You should check L4D2NativeVote_IsAllowNewVote() first.
	//
	// @param handler       Function which will receive VoteAction.
	// @error				There are other vote in progress.
	public native L4D2NativeVote(L4D2VoteHandler handler);

	// Set text displayed on the vote screen.
	//
	// @param fmt           text string format.
	// @param ...           text string arguments.
	public native void SetDisplayText(const char[] fmt, any ...);
	public native void SetTitle(const char[] fmt, any ...);

	// Returns text displayed on the vote screen.
	//
	// @param buffer        Buffer to store text.
	// @param maxlength     Maximum length of the buffer.
	public native void GetDisplayText(char[] buffer, int maxlength);
	public native void GetTitle(char[] buffer, int maxlength);

	// Arbitrary value storage or get.
	property any Value
	{
		public native set(any val);
		public native get();
	}

	// Arbitrary String storage.
	//
	// @param fmt           Info string format.
	// @param ...           Info string arguments.
	public native void SetInfoString(const char[] fmt, any ...);
	public native void SetInfo(const char[] fmt, any ...);

	// Get the stored info string.
	//
	// @param buffer        Buffer to store Info.
	// @param maxlength     Maximum length of the buffer.
	public native void GetInfoString(char[] buffer, int maxlength);
	public native void GetInfo(char[] buffer, int maxlength);

	// Get or set the client index of the player who initiated the vote.
	//
	// Default value 0.
	property int Initiator
	{
		public native set(int client);
		public native get();
	}

	// Broadcasts a vote to a list of clients.  
	//
	// @param clients		Array of clients to broadcast to.
	// @param numClients	Number of clients in the array.
	// @param time			Maximum time to leave vote on the screen.
	// @return				True on success, False if in game numClients < 1 
	//						Or vote is invalid, Or there are other vote in progress.
	public native bool DisplayVote(int[] clients, int numClients, int time);

	// Get or set the current affirmative vote.
	property int YesCount
	{
		public native set(int value);
		public native get();
	}

	// Get or set the current negative vote.
	property int NoCount
	{
		public native set(int value);
		public native get();
	}

	// Get the number of players eligible to vote.
	// Like numClients. but exclude clients that are not in the game.
	property int PlayerCount
	{
		public native get();
	}
	
	// Set vote passed.
	// You must manually call SetPass or SetFail in L4D2VoteHandler.
	//
	// @param fmt           text displayed on the vote screen after passed.
	// @param ...           text string arguments.
	public native void SetPass(const char[] fmt, any ...);

	// Set vote Failed.
	// You must manually call SetPass or SetFail in L4D2VoteHandler.
	public native void SetFail();
}

public SharedPlugin __pl_l4d2_nativevote = 
{
	name = "l4d2_nativevote",
	file = "l4d2_nativevote.smx",
#if defined REQUIRE_PLUGIN
	required = 1,
#else
	required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_l4d2_nativevote_SetNTVOptional()
{
	MarkNativeAsOptional("L4D2NativeVote_IsAllowNewVote");
	MarkNativeAsOptional("L4D2NativeVote.L4D2NativeVote");
	MarkNativeAsOptional("L4D2NativeVote.SetDisplayText");
	MarkNativeAsOptional("L4D2NativeVote.SetTitle");
	MarkNativeAsOptional("L4D2NativeVote.GetDisplayText");
	MarkNativeAsOptional("L4D2NativeVote.GetTitle");
	MarkNativeAsOptional("L4D2NativeVote.Value.set");
	MarkNativeAsOptional("L4D2NativeVote.Value.get");
	MarkNativeAsOptional("L4D2NativeVote.SetInfoString");
	MarkNativeAsOptional("L4D2NativeVote.SetInfo");
	MarkNativeAsOptional("L4D2NativeVote.GetInfoString");
	MarkNativeAsOptional("L4D2NativeVote.GetInfo");
	MarkNativeAsOptional("L4D2NativeVote.Initiator.set");
	MarkNativeAsOptional("L4D2NativeVote.Initiator.get");
	MarkNativeAsOptional("L4D2NativeVote.DisplayVote");
	MarkNativeAsOptional("L4D2NativeVote.YesCount.get");
	MarkNativeAsOptional("L4D2NativeVote.YesCount.set");
	MarkNativeAsOptional("L4D2NativeVote.NoCount.get");
	MarkNativeAsOptional("L4D2NativeVote.NoCount.set");
	MarkNativeAsOptional("L4D2NativeVote.PlayerCount.get");
	MarkNativeAsOptional("L4D2NativeVote.SetPass");
	MarkNativeAsOptional("L4D2NativeVote.SetFail");
}
#endif
