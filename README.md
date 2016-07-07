# SHOUTIT

### ENVIRONMENTS
	* staging
	* local
	* production

### LANES

	* staging

		* Builds staging build and uploads it to crashlytics.
		* Fabric organization: [Shoutit](https://fabric.io/settings/organizations/55cf20e951b1d41b16000038)

	* local

		* Builds local build and uploads it to crashlytics.
		* Fabric organization: [Shoutit](https://fabric.io/settings/organizations/55cf20e951b1d41b16000038)

	* production

		* Builds production build with AppStore configuration and uploads it to TestFlight.
		* tags:
			* production-<number>

	* translations

		* Exports translations from Xcode project and uploads them to public [repo](https://github.com/shoutit/shoutit-ios-xliff)
		* tags:
			* translations-<number>

### BUNDLE IDs

	* staging: com.appunite.shoutit
	* local: com.shoutit-iphone.local
	* production: com.shoutit-iphone

### CODE SIGNING
	
	* staging
		* iPhone Distribution: AppUnite Sp. z o.o. (E6WRHQXQE9)
		* appunite-inhouse.p12
	* local
		* iPhone Distribution: AppUnite Sp. z o.o. (E6WRHQXQE9)
		* appunite-inhouse.p12
	* production
		* iPhone Distribution: Syrex FZ-LLC (2857HUGC3W)
		* shoutit-appstore.p12

### APPLE DEVELOPER ACCOUNT

	* staging - appunite
	* local - appunite
	* production - shoutit@appunite.com

### iTUNES CONNECT

	* staging - appunite
	* local - appunite
	* production - shoutit@appunite.com


