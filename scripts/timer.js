$(function() {
  var apiKey, contentType, host, initSelect, issues, loadOpenAssignedIssues, loadUser, postData, setSelect, submitTimeEntry, user;

  host = "http://ujiroredmine.herokuapp.com";
  user = "/users/current.json";
  issues = "/issues.json?status_id=open&assigned_to_id=";
  contentType = "application/json";
  apiKey = "d8a87e90bb5c59aa786c28be18143cdd993f33c4";
  postData = {
    "time_entry": {
      "issue_id": 0,
      "hours": 0,
      "activity_id": 8,
      "comments": "from Redmine time tracker"
    }
  };
  $(document).ready(function() {
    $("#submitButton").click(submitTimeEntry);
    return initSelect();
  });
  /*
   Api Key の ユーザ
  */

  loadUser = function() {
    return $.ajax({
      type: "GET",
      url: host + user,
      contentType: contentType,
      headers: {
        "X-Redmine-API-Key": apiKey
      },
      success: function(msg) {
        return loadOpenAssignedIssues(msg.user.id);
      }
    });
  };
  /*
   担当のOpenのチケット
  */

  loadOpenAssignedIssues = function(id) {
    console.log("load open assigned issues for " + id);
    return $.ajax({
      type: "GET",
      url: host + issues + id,
      contentType: contentType,
      headers: {
        "X-Redmine-API-Key": apiKey
      },
      success: setSelect
    });
  };
  setSelect = function(msg) {
    var arr;

    arr = $.map(msg.issues, function(issue) {
      return "<option value=\"" + issue.id + "\">#" + issue.id + " " + issue.subject + "</option>";
    });
    return $("#issueSelect").html(arr.join(""));
  };
  initSelect = function() {
    return loadUser();
  };
  return submitTimeEntry = function(e) {
    var issueId;

    e.preventDefault();
    issueId = $('#issueSelect').val();
    postData.time_entry.issue_id = issueId;
    postData.time_entry.hours = 1.0;
    return $.ajax({
      type: "POST",
      url: host + ("/issues/" + issueId + "/time_entries.json"),
      contentType: contentType,
      headers: {
        "X-Redmine-API-Key": apiKey
      },
      data: JSON.stringify(postData),
      dataType: "json",
      success: function(msg) {
        return console.log(msg);
      }
    });
  };
});
