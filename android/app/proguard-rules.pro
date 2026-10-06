# Room instantiates generated *_Impl databases (e.g. WorkManager's
# WorkDatabase_Impl) via reflection; keep their no-arg constructors so R8
# doesn't strip them in release builds.
-keep class * extends androidx.room.RoomDatabase { <init>(); }
