# R8 / release-build keep rules for Homio Essentials.
#
# google_mobile_ads pulls in androidx.work (WorkManager). WorkManager creates its Room database through
# reflection (androidx.work.impl.WorkDatabase -> WorkDatabase_Impl). Without these rules R8 strips or alters
# the generated *_Impl class and the app dies in androidx.startup.InitializationProvider before Flutter even
# starts: "RuntimeException: Failed to create an instance of androidx.work.impl.WorkDatabase".
-keep class androidx.work.impl.WorkDatabase_Impl { *; }
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.** { *; }
-dontwarn androidx.work.**
