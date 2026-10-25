#if defined _Forgetest_vtimers_included_
	#endinput
#endif
#define _Forgetest_vtimers_included_

#include <sourcemod>

methodmap CountdownTimerPtr
{
	public void Reset() {
		this.m_timestamp = GetGameTime() + this.m_duration;
	}
	public void Start( float duration ) {
		this.m_timestamp = GetGameTime() + duration;
		this.m_duration = duration;
	}
	public bool HasStarted() {
		return this.m_timestamp > 0.0;
	}
	public void Invalidate() {
		this.m_timestamp = -1.0;
	}
	public bool IsElasped() {
		return GetGameTime() >= this.m_timestamp;
	}
	public float GetElapsedTime() {
		return GetGameTime() - this.m_timestamp + this.m_duration;
	}
	public float GetRemainingTime() {
		return this.m_timestamp - GetGameTime();
	}
	public float GetCountdownDuration() {
		return (this.m_timestamp > 0.0) ? this.m_duration : 0.0;
	}
	property float m_duration {
		public get() { return LoadFromAddress(view_as<Address>(this) + view_as<Address>(4), NumberType_Int32); }
		public set(float duration) { StoreToAddress(view_as<Address>(this) + view_as<Address>(4), duration, NumberType_Int32); }
	}
	property float m_timestamp {
		public get() { return LoadFromAddress(view_as<Address>(this) + view_as<Address>(8), NumberType_Int32); }
		public set(float timestamp) { StoreToAddress(view_as<Address>(this) + view_as<Address>(8), timestamp, NumberType_Int32); }
	}
}

methodmap IntervalTimerPtr
{
	public void Reset() {
		this.m_timestamp = GetGameTime();
	}
	public void Start() {
		this.m_timestamp = GetGameTime();
	}
	public bool HasStarted() {
		return (this.m_timestamp > 0.0);
	}
	public void Invalidate() {
		this.m_timestamp = -1.0;
	}
	public float GetElapsedTime() {
		return (this.HasStarted()) ? (GetGameTime() - this.m_timestamp) : 99999.9;
	}
	public bool IsLessThen( float duration ) {
		return (GetGameTime() - this.m_timestamp < duration) ? true : false;
	}
	public bool IsGreaterThen( float duration ) {
		return (GetGameTime() - this.m_timestamp > duration) ? true : false;
	}
	property float m_timestamp {
		public get() { return LoadFromAddress(view_as<Address>(this) + view_as<Address>(4), NumberType_Int32); }
		public set(float timestamp) { StoreToAddress(view_as<Address>(this) + view_as<Address>(4), timestamp, NumberType_Int32); }
	}
}