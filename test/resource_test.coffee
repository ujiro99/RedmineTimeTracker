expect = chai.expect

describe 'resource.coffee', ->

  Resource = null
  $translate = null


  beforeEach () ->
    module 'timeTracker', ($translateProvider) ->
      $translateProvider.translations('en', {
        "dialogRemoveAccountConfirm": {
          "message": "Are you sure you want to remove the account?"
        }
      })
      $translateProvider.translations('pl', {
        "extDescription": {
          "message": "Zarządza czasem w zadaniach i synchronizuje je z serwerem.",
        }
      })
      $translateProvider.translations('en', {
        "extDescription": {
          "message": "Track your work time, and posts to Redmine server.",
        },
      })
      $translateProvider.translations('ja', {
        "extDescription": {
          "message": "作業時間を計測し、Redmineサーバへ記録します.",
        },
        "msgAccountRemoved": {
          "message": "\"{{arg0}}\" は削除しました."
        },
        "msgSubmitTimeEntry": {
          "message": "保存中 {{arg0}}: {{arg1}}"
        },
      })

      $translateProvider.preferredLanguage('en')
      $translateProvider.fallbackLanguage('en')
      $translateProvider.useSanitizeValueStrategy('escape')
      return

    inject (_Resource_, _$translate_) ->
      Resource = _Resource_
      $translate = _$translate_


  describe 'string(key, data)', ->

    it 'returns Japanese', () ->
      $translate.use('ja')
      str = Resource.string('extDescription')
      expect(str).to.equal('作業時間を計測し、Redmineサーバへ記録します.')

    it 'returns Japanese, using a data.', () ->
      $translate.use('ja')
      str = Resource.string('msgAccountRemoved', 'test')
      expect(str).to.equal('\"test\" は削除しました.')

    it 'returns Japanese, using two data.', () ->
      $translate.use('ja')
      str = Resource.string('msgSubmitTimeEntry', ['test', 1])
      expect(str).to.equal('保存中 test: 1')

    it 'returns English', () ->
      str = Resource.string('dialogRemoveAccountConfirm')
      expect(str).to.equal('Are you sure you want to remove the account?')

    it 'returns English, if Japanese sentence don\'t exists.', () ->
      $translate.use('ja')
      str = Resource.string('dialogRemoveAccountConfirm')
      expect(str).to.equal('Are you sure you want to remove the account?')

    it 'returns Polish', () ->
      $translate.use('pl')
      str = Resource.string('extDescription')
      expect(str).to.equal('Zarządza czasem w zadaniach i synchronizuje je z serwerem.')
