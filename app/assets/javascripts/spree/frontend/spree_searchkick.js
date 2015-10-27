// Placeholder manifest file.
// the installer will append this file to the app vendored assets here: vendor/assets/javascripts/spree/frontend/all.js'
//= require_tree .
$(function () {

  var products = new Bloodhound({
    datumTokenizer: Bloodhound.tokenizers.whitespace,
    queryTokenizer: Bloodhound.tokenizers.whitespace,
    limit: 10,
    //prefetch: '/autocomplete/products.json',
    remote: {
      url: '/autocomplete/products.json?keywords=%QUERY', 
      wildcard: '%QUERY'
        }
      });

  products.initialize();

  // passing in `null` for the `options` arguments will result in the default
  // options being used
  $('#keywords').typeahead({
    minLength: 2,
    highlight: true
  }, {
    name: 'products',
    displayKey: 'name',
    source: products,
    templates: {
      empty: [
      '<div class="tt-empty">',
      '<p class="text-center">Sorry, leider nichts gefunden.</p>',
      '</div>'
      ].join('\n'),
      suggestion: Handlebars.compile('<div class="search-result"><div class="image" style="background-image: url({{image}})"></div><div class="brand">{{brand}}</div><div class="title">{{name}}</div><div class="taxons">{{taxons}}</div></div>'),
      header: [
      '<div class="center-block seach-header">',
      '<p class="text-center altmann-blau">Altmanndental immer für Sie da!</p>',
      '</div>'].join('\n'), 
      footer: [
      '<div class="search-footer">',
      '',
      '</div>'].join('\n'),
      pending: ['<p class="text-center">Searching....</p>']
    }
  });

$('#keywords').bind('typeahead:select', function(ev, suggestion) {
  document.location.href = "/products/" + suggestion.id;
});

});