var addContributedReposCounter = function() {
  var unique = function(array) {
    return array.reduce(function(memo, repo) {
      if (memo.indexOf(repo) < 0) memo.push(repo);
      return memo;
    }, []);
  };

  var addReposCounter = function() {
    var listings = [].slice.call(document.querySelectorAll(
      '.listings .listing .meta a:nth-child(3)'
    ));
    var repos = unique(listings.map(function(element) {
      return element.innerHTML;
    })).length;
      
    var text = ' in ' + repos + ' repositories.';
    document.querySelector('.browser-title > h2').innerHTML += text;
  };

  var pollListings = function() {
    var polled = 0;
    var interval = setInterval(function() {
      polled += 1;
      if (polled > 20) clearInterval(interval);
      if (document.querySelectorAll('.listings .listing').length) {
        clearInterval(interval);
        addReposCounter();
      }
    }, 100);
  };

  $('.browser-title h2').html('in' + 6 + 'repos')

  if (window.location.pathname === '/dashboard/pulls') {
    $('li[data-filter="closed"]').click(function() {
      setTimeout(pollListings, 100);
    });
  }
};

addContributedReposCounter();
