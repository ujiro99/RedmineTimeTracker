var validTopicTab = false;
var xdaUtils = new XdaUtils();

// *********************************************************
// Entry Point
// *********************************************************

chrome.extension.onMessage.addListener(
		function(request, sender, sendResponse) {
			if (request.method == "getXdaTopic"){
				console.log("Received Message From Gallery Detail: " + request.method);
				console.log("For tabId " + request.tabId);

				chrome.tabs.get(request.tabId,
					function(tab){
						xdaUtils.getTopicFromUrl(tab.url, function(xdaTopic){
							if(xdaTopic){
								sendResponse({xdaTopic: xdaTopic});
							}else{
								sendResponse({xdaTopic: null});
							}
						});
					}
				);

				// Return to let sender know we received the request
				return(true);
			}
		}
	);

chrome.browserAction.onClicked.addListener(
		function(tab){
			if(validTopicTab){
				chrome.tabs.create(
					{
						'url': chrome.extension.getURL('/views/galleryDetail.html'),
						openerTabId: tab.id
					}
				);
			}
		}
	);

// *********************************************************
// Add listeners for tab actions to change URL for XDA topic
// *********************************************************
chrome.tabs.onUpdated.addListener(
	function(tabId, changeInfo, tab) {
		checkIfTabIsValidTopic(tab.url);
	}
);

chrome.tabs.onActivated.addListener(
	function(activeInfo){
		chrome.tabs.get(activeInfo.tabId,
			function(tab){
				checkIfTabIsValidTopic(tab.url);
			}
		);
	}
);

function checkIfTabIsValidTopic(url){
	if(url !== null){
		if(xdaUtils.isValidTopicUrl(url)){
			validTopicTab = true;
			chrome.browserAction.setIcon({path: "/images/icon.png"});
		} else {
			validTopicTab = false;
			chrome.browserAction.setIcon({path: "/images/icon-disabled.png"});
		}
	}
	return validTopicTab;
}
