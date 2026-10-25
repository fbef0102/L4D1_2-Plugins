#if defined _l4d_tank_damage_announce_uservector_included
 #endinput
#endif
#define _l4d_tank_damage_announce_uservector_included

/**
 * Entity-Relationship: UserVector(Userid, ...)
 */
typeset UserVectorIterate
{
	function bool (int userid);
	function bool (int userid, any data);
}
methodmap UserVector < ArrayList
{
	public UserVector(int blocksize = 1) {
		return view_as<UserVector>(new ArrayList(blocksize, 0));
	}
	property ArrayList Super {
		public get() { return view_as<ArrayList>(this); }
	}
	public int FindOrCreate(int userid, bool create = false) {
		int index = this.FindValue(userid, 0);
		if (index == -1 && create) {
			any[] o = new any[this.BlockSize];
			o[0] = userid;
			for (int i = 1; i < this.BlockSize; ++i) { o[i] = 0; }
			index = this.PushArray(o);
		}
		return index;
	}
	public int At(int index) {
		return this.Super.Get(index, 0);
	}
	public bool Get(int userid, any &value, int block = 0) {
		int index = this.FindOrCreate(userid);
		if (index != -1) value = this.Super.Get(index, block);
		return index != -1;
	}
	public bool Set(int userid, any value, int block = 0) {
		int index = this.FindOrCreate(userid);
		if (index != -1) value = this.Super.Set(index, value, block);
		return index != -1;
	}
	public bool Erase(int userid) {
		int index = this.FindOrCreate(userid);
		if (index != -1) this.Super.Erase(index);
		return index != -1;
	}
	public bool GetArray(int userid, any[] value) {
		int index = this.FindOrCreate(userid);
		if (index != -1) this.Super.GetArray(index, value);
		return index != -1;
	}
	public bool Add(int userid, any value, int block = 0) {
		any temp;
		return this.Get(userid, temp, block) && this.Set(userid, temp + value, block);
	}
	public any Sum(int block) {
		int size = this.Length;
		any result = 0;
		for (int i = 0; i < size; ++i) { result += this.Super.Get(i, block); }
		return result;
	}
	public bool ForEach(UserVectorIterate callback, any data = 0) {
		int size = this.Length;
		bool result = false;
		for (int i = 0; i < size; ++i) {
			Call_StartFunction(INVALID_HANDLE, callback);
			Call_PushCell(this.At(i));
			Call_PushCell(data);
			Call_Finish(result);
			if (!result) return false;
		}
		return true;
	}
}

// pawn doesn't implement methodmap VTable-like, so I have to copy paste the whole thing here :(
methodmap AutoUserVector < ArrayList {
	public AutoUserVector(int blocksize = 1) {
		return view_as<AutoUserVector>(new ArrayList(blocksize));
	}
	property ArrayList Super {
		public get() { return view_as<ArrayList>(this); }
	}
	public int FindOrCreate(int userid) {
		int index = this.FindValue(userid, 0);
		if (index == -1) {
			any[] o = new any[this.BlockSize];
			o[0] = userid;
			for (int i = 1; i < this.BlockSize; ++i) { o[i] = 0; }
			index = this.PushArray(o);
		}
		return index;
	}
	public int At(int index) {
		return this.Super.Get(index, 0);
	}
	public bool Get(int userid, any &value, int block = 0) {
		int index = this.FindOrCreate(userid);
		if (index != -1) value = this.Super.Get(index, block);
		return index != -1;
	}
	public bool Set(int userid, any value, int block = 0) {
		int index = this.FindOrCreate(userid);
		if (index != -1) value = this.Super.Set(index, value, block);
		return index != -1;
	}
	public bool Erase(int userid) {
		int index = this.FindOrCreate(userid);
		if (index != -1) this.Super.Erase(index);
		return index != -1;
	}
	public bool GetArray(int userid, any[] value) {
		int index = this.FindOrCreate(userid);
		if (index != -1) this.Super.GetArray(index, value);
		return index != -1;
	}
	public bool Add(int userid, any value, int block = 0) {
		any temp;
		return this.Get(userid, temp, block) && this.Set(userid, temp + value, block);
	}
	public any Sum(int block) {
		int size = this.Length;
		any result = 0;
		for (int i = 0; i < size; ++i) { result += this.Super.Get(i, block); }
		return result;
	}
	public bool ForEach(UserVectorIterate callback, any data = 0) {
		int size = this.Length;
		bool result = false;
		for (int i = 0; i < size; ++i) {
			Call_StartFunction(INVALID_HANDLE, callback);
			Call_PushCell(this.At(i));
			Call_PushCell(data);
			Call_Finish(result);
			if (!result) return false;
		}
		return true;
	}
}