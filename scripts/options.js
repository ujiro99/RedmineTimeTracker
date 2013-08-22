/*
 * Author: Ara Yapejian
 */

var _gaq = _gaq || [];
_gaq.push(['_setAccount', 'UA-36762911-1']);
_gaq.push(['_trackPageview']);

(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = 'https://ssl.google-analytics.com/ga.js';
  var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
})();

function ExtensionOptions() {
	this.navigation = {};

	this.options = {
		imagesToFetch: {
			name: 'imagesToFetch',
			value: {},
			defaultValue: 15,
			control: {},
			settingNameValue: {}
		},
		debugMode: {
			name: 'debugMode',
			value: {},
			defaultValue: false,
			control: {},
			settingNameValue: {}
		},
		overrideNumImageFetch: {
			name: 'overrideNumImageFetch',
			value: {},
			defaultValue: false,
			control: {},
			settingNameValue: {}
		}
	};
}

/**
 * Stores the option in Chrome's online storage or locally if not available
 */
ExtensionOptions.prototype.storeOptions = function(options){

	if(options){
		// Save the settings object
		chrome.storage.sync.set({"options": options}, function(){
			// Nothing to do here
		});
	}
};

/**
 * Returns all options stored as an object, gets returned in callback
 */
ExtensionOptions.prototype.getOptions = function(callback){
	chrome.storage.sync.get("options", function(items){
		callback(items.options);
	});
};

ExtensionOptions.prototype.setDebug = function(enabled){

	if(enabled === true){
		this.options.debugMode.settingNameValue.html("On");
		this.options.debugMode.value = true;
	}else{
		this.options.debugMode.settingNameValue.html("Off");
		this.options.debugMode.value = false;
	}

	// Set the input element if it's not set
	this.options.debugMode.control.prop('checked', this.options.debugMode.value);

	this.storeOptions(this.options);
};

ExtensionOptions.prototype.setOverrideImagesToFetch= function(enabled){

	if(enabled === true){
		this.options.overrideNumImageFetch.settingNameValue.html("On");
		this.options.overrideNumImageFetch.value = true;
		this.setImagesToFetch("numImageFetchOverride");
	}else{
		this.options.overrideNumImageFetch.settingNameValue.html("Off");
		this.options.overrideNumImageFetch.value = false;
		this.setImagesToFetch(this.options.imagesToFetch.value);
	}

	// Set the input element if it's not set
	this.options.overrideNumImageFetch.control.prop('checked', this.options.overrideNumImageFetch.value);

	this.storeOptions(this.options);
};

ExtensionOptions.prototype.setImagesToFetch = function(value){

	// numImageFetchOverride is on, disable this option
	if(value == "numImageFetchOverride"){
		this.options.imagesToFetch.control.prop('disabled', true);
		this.options.imagesToFetch.settingNameValue.addClass("warning");
		this.options.imagesToFetch.settingNameValue.html("Fetch all images override");
	}else{
		if(isNaN(value)){
			value = this.options.imagesToFetch.defaultValue;
		}

		this.options.imagesToFetch.settingNameValue.removeClass("warning");
		this.options.imagesToFetch.control.prop('disabled', false);
		// There is a bug with this in Chrome that causes the slider to jump around
		// but the correct value is set.
		// TODO: Test in stable chrome version and use if it's good, otherwise
		// put in checkbox group
		this.options.imagesToFetch.control.val(parseInt(value, 10));

		this.options.imagesToFetch.value = value;
		this.options.imagesToFetch.settingNameValue.html(value);

		this.storeOptions(this.options);
	}
};

ExtensionOptions.prototype.init = function(){
	var that = this;
	var options = that.options;

	that.navigation = $("#navigation");

	// First fetch all the controls and html elements
	options.imagesToFetch.control = $("#imagesToFetchInput");
	options.imagesToFetch.settingNameValue = $("#imagesToFetchSettingsSection .setting-name-value");

	options.debugMode.control = $("#debugModeInput");
	options.debugMode.settingNameValue = $("#debugModeSettingSection .setting-name-value");

	options.overrideNumImageFetch.control = $("#overrideNumImageFetchInput");
	options.overrideNumImageFetch.settingNameValue = $("#overrideNumImageFetchSettingSection .setting-name-value");

	// Load the settings from storage, when done set the UI up
	that.loadSettings(function(){
		that.setDebug(options.debugMode.value);
		that.setImagesToFetch(options.imagesToFetch.value);
		that.setOverrideImagesToFetch(options.overrideNumImageFetch.value);
	});

	this.setupEventBinding();
};

ExtensionOptions.prototype.setupEventBinding = function(){
	var that = this;
	var options = that.options;

	// Setup page navigation events
	this.navigation.on('click', 'li', function(){
		that.showSettingsPage(this.attributes.getNamedItem('controls').value);
	});

	// Setup Option Control Events
	// Number of images to fetch
	options.imagesToFetch.control.change(function(){
		that.setImagesToFetch(this.value);
	});

	// Debug Mode
	options.debugMode.control.click(function(){
		that.setDebug(this.checked);
	});

	// Debug Mode
	options.overrideNumImageFetch.control.click(function(){
		that.setOverrideImagesToFetch(this.checked);
	});
};

ExtensionOptions.prototype.showSettingsPage = function(controlsAttribute){
	// Being lazy
	if(controlsAttribute == "general"){
		$("#general").addClass("pageSelected");
		$("#advanced").removeClass("pageSelected");

		$("#navGeneral").addClass("selected");
		$("#navAdvanced").removeClass("selected");
	}else if (controlsAttribute == "advanced"){
		$("#advanced").addClass("pageSelected");
		$("#general").removeClass("pageSelected");

		$("#navAdvanced").addClass("selected");
		$("#navGeneral").removeClass("selected");
	}
};

/**
 * Fetches and sets the option value's of this instance of the class, or sets
 * to defaults if not found.  Callback is called when done.
 */
ExtensionOptions.prototype.loadSettings = function(callback){
	var that = this;
	var options = this.options;

	that.getOptions(function(fetchedOptions){

		if(fetchedOptions){
			// Get the Debug Mode Option
			if(fetchedOptions[options.debugMode.name]){
				options.debugMode.value = fetchedOptions[options.debugMode.name].value;
			} else {
				options.debugMode.value = options.debugMode.defaultValue;
			}

			// Get the Images to load options
			if(fetchedOptions[options.imagesToFetch.name]){
				options.imagesToFetch.value = fetchedOptions[options.imagesToFetch.name].value;
			} else {
				options.imagesToFetch.value = options.imagesToFetch.defaultValue;
			}

			// Get the Override Image Fetch Number option
			if(fetchedOptions[options.overrideNumImageFetch.name]){
				options.overrideNumImageFetch.value = fetchedOptions[options.overrideNumImageFetch.name].value;
			} else {
				options.overrideNumImageFetch.value = options.overrideNumImageFetch.defaultValue;
			}
		}

		callback();
	});
};


$(function(){
	var extensionOptions = new ExtensionOptions();

	// For testing setting defaults
	if(false){
		chrome.storage.sync.clear(function(){
			extensionOptions.init();
		});
	}else{
		extensionOptions.init();
	}
});
