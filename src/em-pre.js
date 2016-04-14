var Module;
if (typeof Module === 'undefined') Module = eval('(function() { try { return Module || {} } catch(e) { return {} } })()');

Module['preRun'] = function () {
    FS.createPreloadedFile(
        '/', // 親フォルダの指定
        '/home/web_user/test.png', // ソース中でのファイル名
        '/test.png', // httpでアクセスする際のURLを指定
        true, // 読み込み許可
        false // 書き込み許可
    );
};
