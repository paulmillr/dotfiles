(() => {
let itemName = new URL(window.location.href).searchParams.get('itemName');
let [publisher, extension] = itemName.split('.');
let version = document.querySelector('#versionHistoryTab tbody tr .version-history-container-column').textContent;
let URL_VSIX_PATTERN = 'https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${publisher}/vsextensions/${extension}/${version}/vspackage';
let url = URL_VSIX_PATTERN.replace('${publisher}', publisher).replace('${extension}', extension).replace('${version}', version);
// window.open(url, '_blank');
console.log(url);
})();