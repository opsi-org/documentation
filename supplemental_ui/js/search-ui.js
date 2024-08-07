(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? factory(exports) :
    typeof define === 'function' && define.amd ? define(['exports'], factory) :
    (global = typeof globalThis !== 'undefined' ? globalThis : global || self, factory(global.antoraSearch = {}));
})(this, (function (exports) {
  'use strict';

  function buildHighlightedText(text, positions, snippetLength) {
    const textLength = text.length;
    const validPositions = positions
      .filter((position) => position.length > 0 && position.start + position.length <= textLength);

    if (validPositions.length === 0) {
      return [{
        type: 'text',
        text: text.slice(0, snippetLength >= textLength ? textLength : snippetLength) + (snippetLength < textLength ? '...' : ''),
      }, ]
    }

    const orderedPositions = validPositions.sort((p1, p2) => p1.start - p2.start);
    const range = {
      start: 0,
      end: textLength,
    };
    const firstPosition = orderedPositions[0];
    if (snippetLength && text.length > snippetLength) {
      const firstPositionStart = firstPosition.start;
      const firstPositionLength = firstPosition.length;
      const firstPositionEnd = firstPositionStart + firstPositionLength;

      range.start = firstPositionStart - snippetLength < 0 ? 0 : firstPositionStart - snippetLength;
      range.end = firstPositionEnd + snippetLength > textLength ? textLength : firstPositionEnd + snippetLength;
    }
    const nodes = [];
    if (firstPosition.start > 0) {
      nodes.push({
        type: 'text',
        text: (range.start > 0 ? '...' : '') + text.slice(range.start, firstPosition.start),
      });
    }
    let lastEndPosition = 0;
    const positionsWithinRange = orderedPositions
      .filter((position) => position.start >= range.start && position.start + position.length <= range.end);

    for (const position of positionsWithinRange) {
      const start = position.start;
      const length = position.length;
      const end = start + length;
      if (lastEndPosition > 0) {
        // create text Node from the last end position to the start of the current position
        nodes.push({
          type: 'text',
          text: text.slice(lastEndPosition, start),
        });
      }
      nodes.push({
        type: 'mark',
        text: text.slice(start, end),
      });
      lastEndPosition = end;
    }
    if (lastEndPosition < range.end) {
      nodes.push({
        type: 'text',
        text: text.slice(lastEndPosition, range.end) + (range.end < textLength ? '...' : ''),
      });
    }

    return nodes
  }

  /**
   * Taken and adapted from: https://github.com/olivernn/lunr.js/blob/aa5a878f62a6bba1e8e5b95714899e17e8150b38/lib/tokenizer.js#L24-L67
   * @param lunr
   * @param text
   * @param term
   * @return {{start: number, length: number}}
   */
  function findTermPosition(lunr, term, text) {
    const str = text.toLowerCase();
    const len = str.length;

    for (let sliceEnd = 0, sliceStart = 0; sliceEnd <= len; sliceEnd++) {
      const char = str.charAt(sliceEnd);
      const sliceLength = sliceEnd - sliceStart;

      if ((char.match(lunr.tokenizer.separator) || sliceEnd === len)) {
        if (sliceLength > 0) {
          const value = str.slice(sliceStart, sliceEnd);
          // QUESTION: if we get an exact match without running the pipeline should we stop?
          if (value.includes(term)) {
            // returns the first match
            return {
              start: sliceStart,
              length: value.length,
            }
          }
        }
        sliceStart = sliceEnd + 1;
      }
    }

    // not found!
    return {
      start: 0,
      length: 0,
    }
  }

  /* global CustomEvent, globalThis */

  const config = document.getElementById('search-ui-script').dataset;
  const snippetLength = parseInt(config.snippetLength || 100, 10);
  const siteRootPath = config.siteRootPath || '';
  appendStylesheet(config.stylesheet);
  const searchInput = document.getElementById('search-input');
  const searchResultContainer = document.createElement('div');
  searchResultContainer.classList.add('search-result-dropdown-menu');
  searchInput.parentNode.appendChild(searchResultContainer);
  const componentFilterInput = document.querySelector('#search-field input[type=checkbox][data-component-filter]');
  const versionFilterInput = document.querySelector('#search-field input[type=checkbox][data-version-filter]');

  function appendStylesheet(href) {
    if (!href) return
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.href = href;
    document.head.appendChild(link);
  }

  function highlightPageTitle(title, terms) {
    const positions = getTermPosition(title, terms);
    return buildHighlightedText(title, positions, snippetLength)
  }

  function highlightSectionTitle(sectionTitle, terms) {
    if (sectionTitle) {
      const text = sectionTitle.text;
      const positions = getTermPosition(text, terms);
      return buildHighlightedText(text, positions, snippetLength)
    }
    return []
  }

  function highlightText(doc, terms) {
    const text = doc.text;
    const positions = getTermPosition(text, terms);
    return buildHighlightedText(text, positions, snippetLength)
  }

  function getTermPosition(text, terms) {
    const positions = terms
      .map((term) => findTermPosition(globalThis.lunr, term, text))
      .filter((position) => position.length > 0)
      .sort((p1, p2) => p1.start - p2.start);

    if (positions.length === 0) {
      return []
    }
    return positions
  }

  function highlightHit(searchMetadata, sectionTitle, doc) {
    const terms = {};
    for (const term in searchMetadata) {
      const fields = searchMetadata[term];
      for (const field in fields) {
        terms[field] = [...(terms[field] || []), term];
      }
    }
    return {
      pageTitleNodes: highlightPageTitle(doc.title, terms.title || []),
      sectionTitleNodes: highlightSectionTitle(sectionTitle, terms.title || []),
      pageContentNodes: highlightText(doc, terms.text || []),
    }
  }

  function createSearchResult(result, store, searchResultDataset, query) {
    // console.log("createSearchResult");
    let currentComponent
    result.forEach(function (item) {
      const ids = item.ref.split('-')
      const docId = ids[0]
      const doc = store.documents[docId]
      let sectionTitle
      if (ids.length > 1) {
        const titleId = ids[1]
        sectionTitle = doc.titles.filter(function (item) {
          return String(item.id) === titleId
        })[0]
      }
      const metadata = item.matchData.metadata
      const highlightingResult = highlightHit(metadata, sectionTitle, doc)
      const componentVersion = store.componentVersions[`${doc.component}/${doc.version}`]
      if (componentVersion !== undefined && currentComponent !== componentVersion) {
        const searchResultComponentHeader = document.createElement('div')
        searchResultComponentHeader.classList.add('search-result-component-header')
        const {
          title,
          displayVersion
        } = componentVersion
        const componentVersionText = `${title}${doc.version && displayVersion ? ` ${displayVersion}` : ''}`
        searchResultComponentHeader.appendChild(document.createTextNode(componentVersionText))
        searchResultDataset.appendChild(searchResultComponentHeader)
        currentComponent = componentVersion
      }
      searchResultDataset.appendChild(createSearchResultItem(doc, sectionTitle, item, highlightingResult, query))
    })
  }


  function createSearchResultItem(doc, sectionTitle, item, highlightingResult, query) {
    // console.log("createSearchResultItem");
    const documentTitle = document.createElement('div')
    documentTitle.classList.add('search-result-document-title')
    highlightingResult.pageTitleNodes.forEach(function (node) {
      let element
      if (node.type === 'text') {
        element = document.createTextNode(node.text)
      } else {
        element = document.createElement('span')
        element.classList.add('search-result-highlight')
        element.innerText = node.text
      }
      documentTitle.appendChild(element)
    })
    const documentHit = document.createElement('div')
    documentHit.classList.add('search-result-document-hit')
    const documentHitLink = document.createElement('a')

    //documentHitLink.href = siteRootPath + doc.url + (sectionTitle ? '#' + sectionTitle.hash : '')
    //set query param to search query
    let url = new URL(siteRootPath + doc.url, window.location.href)
    if (sectionTitle) {
      url.hash = '#' + sectionTitle.hash
    }
    url.searchParams.set('q', query)
    documentHitLink.href = url.href

    documentHit.appendChild(documentHitLink)
    if (highlightingResult.sectionTitleNodes.length > 0) {
      const documentSectionTitle = document.createElement('div')
      documentSectionTitle.classList.add('search-result-section-title')
      documentHitLink.appendChild(documentSectionTitle)
      highlightingResult.sectionTitleNodes.forEach(function (node) {
        let element
        if (node.type === 'text') {
          element = document.createTextNode(node.text)
        } else {
          element = document.createElement('span')
          element.classList.add('search-result-highlight')
          element.innerText = node.text
        }
        //set query param to title hit
        url = new URL(siteRootPath + doc.url, window.location.href)
        if (sectionTitle) {
          url.hash = '#' + sectionTitle.hash
        }
        url.searchParams.set('q', node.text)
        documentHitLink.href = url.href
        documentSectionTitle.appendChild(element)
      })
    }
    //set query param to text hit
    highlightingResult.pageContentNodes.forEach(function (node) {
      let element
      if (node.type === 'text') {
        element = document.createTextNode(node.text)
      } else {
        element = document.createElement('span')
        element.classList.add('search-result-highlight')
        element.innerText = node.text
        url = new URL(siteRootPath + doc.url, window.location.href)
        if (sectionTitle) {
          url.hash = '#' + sectionTitle.hash
        }
        url.searchParams.set('q', node.text)
        documentHitLink.href = url.href
      }

      documentHitLink.appendChild(element)
    })
    const searchResultItem = document.createElement('div')
    searchResultItem.classList.add('search-result-item')
    searchResultItem.appendChild(documentTitle)
    searchResultItem.appendChild(documentHit)
    searchResultItem.addEventListener('mousedown', function (e) {
      e.preventDefault()
    })
    return searchResultItem
  }

  function createNoResult(text) {
    const searchResultItem = document.createElement('div');
    searchResultItem.classList.add('search-result-item');
    const documentHit = document.createElement('div');
    documentHit.classList.add('search-result-document-hit');
    const message = document.createElement('strong');
    message.innerText = 'No results found for query "' + text + '"';
    documentHit.appendChild(message);
    searchResultItem.appendChild(documentHit);
    return searchResultItem
  }

  function clearSearchResults(reset) {
    if (reset === true) searchInput.value = '';
    searchResultContainer.innerHTML = '';
  }

  function filter(result, documents) {
    const componentFilter = componentFilterInput && componentFilterInput.checked && componentFilterInput.dataset.componentFilter;
    const versionFilter = versionFilterInput && versionFilterInput.checked && versionFilterInput.dataset.versionFilter;
    if (componentFilter || versionFilter) {

      return result.filter((item) => {
        const ids = item.ref.split('-');
        const docId = ids[0];
        const doc = documents[docId];
        if (componentFilter && versionFilter) {
          const [component, componentTitle] = componentFilter.split(":");
          const [version, versionValue] = versionFilter.split(":");
          return component in doc && doc[component] === componentTitle && version in doc && doc[version] === versionValue
        } else if (componentFilter) {
          const [component, componentTitle] = componentFilter.split(":");
          return component in doc && doc[component] === componentTitle
        } else {
          const [version, versionValue] = componentFilter.split(":");
          version in doc && doc[version] === versionValue
        }
      })
    }
    return result
  }

  function search(index, documents, queryString) {
    // execute an exact match search
    let query;
    let result = filter(
      index.query(function (lunrQuery) {
        const parser = new globalThis.lunr.QueryParser(queryString, lunrQuery);
        parser.parse();
        query = lunrQuery;
      }),
      documents
    );
    if (result.length > 0) {
      return result
    }
    // no result, use a begins with search
    result = filter(
      index.query(function (lunrQuery) {
        lunrQuery.clauses = query.clauses.map((clause) => {
          if (clause.presence !== globalThis.lunr.Query.presence.PROHIBITED) {
            clause.term = clause.term + '*';
            clause.wildcard = globalThis.lunr.Query.wildcard.TRAILING;
            clause.usePipeline = false;
          }
          return clause
        });
      }),
      documents
    );
    if (result.length > 0) {
      return result
    }
    // no result, use a contains search
    result = filter(
      index.query(function (lunrQuery) {
        lunrQuery.clauses = query.clauses.map((clause) => {
          if (clause.presence !== globalThis.lunr.Query.presence.PROHIBITED) {
            clause.term = '*' + clause.term + '*';
            clause.wildcard = globalThis.lunr.Query.wildcard.LEADING | globalThis.lunr.Query.wildcard.TRAILING;
            clause.usePipeline = false;
          }
          return clause
        });
      }),
      documents
    );
    return result
  }

  function searchIndex(index, store, text) {
    clearSearchResults(false);
    if (text.trim() === '') {
      return
    }
    const result = search(index, store.documents, text);
    const searchResultDataset = document.createElement('div');
    searchResultDataset.classList.add('search-result-dataset');
    searchResultContainer.appendChild(searchResultDataset);
    if (result.length > 0) {
      createSearchResult(result, store, searchResultDataset, text);
    } else {
      searchResultDataset.appendChild(createNoResult(text));
    }
  }

  function confineEvent(e) {
    e.stopPropagation();
  }

  function debounce(func, wait, immediate) {
    let timeout;
    return function () {
      const context = this;
      const args = arguments;
      const later = function () {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };
      const callNow = immediate && !timeout;
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
      if (callNow) func.apply(context, args);
    }
  }

  function enableSearchInput(enabled) {
    if (componentFilterInput) {
      componentFilterInput.disabled = !enabled;
    }
    searchInput.disabled = !enabled;
    searchInput.title = enabled ? '' : 'Loading index...';
  }

  function isClosed() {
    return searchResultContainer.childElementCount === 0
  }

  function executeSearch(index) {
    const debug = 'URLSearchParams' in globalThis && new URLSearchParams(globalThis.location.search).has('lunr-debug');
    const query = searchInput.value;
    try {
      if (!query) return clearSearchResults()
      searchIndex(index.index, index.store, query);
    } catch (err) {
      if (err instanceof globalThis.lunr.QueryParseError) {
        if (debug) {
          console.debug('Invalid search query: ' + query + ' (' + err.message + ')');
        }
      } else {
        console.error('Something went wrong while searching', err);
      }
    }
  }

  function toggleFilter(e, index) {
    searchInput.focus();
    if (!isClosed()) {
      executeSearch(index);
    }
  }




  function highliteMatches() {
    const params = new URLSearchParams(window.location.search.slice(1))

    const query = params.get('q')

    if (query == undefined || query == null) return
    searchWord(query)

  }


  function searchWord(searchText) {

    // console.log(searchText);
    // console.log(window.location.href.includes("#"));
    if (window.location.href.includes("#")) {
      // let url = window.location.href.split("?")
      // window.location.href =  url[0] + "#" + url[1].split("#")[1];

      history.replaceState && history.replaceState(
        null, '', location.pathname + location.search.replace(/[\?&]q=[^&]+/, '').replace(/^&/, '?') + location.hash
      );


    } else {
      history.replaceState && history.replaceState(
        null, '', location.pathname + location.search.replace(/[\?&]q=[^&]+/, '').replace(/^&/, 'q=null') + location.hash
      );

      // let sections = document.getElementsByClassName("sect1");
      // let article = document.querySelectorAll("article")
      // console.log(document.querySelectorAll("body > div > main > div.content > article > div.sect1 > div"));
      // console.log(document.querySelectorAll("sectionbody.admonitionblock"));
      // let sections = document.querySelectorAll("p") + document.getElementsByClassName("sectionbody.imageblock") + document.getElementsByClassName("sectionbody.admonitionblock");
      // let sections = document.getElementsByClassName("sectionbody");

      // let sections = document.querySelectorAll("body > div > main > div.content > article :not(.toc-menu) :not(.anchor)");
      let sections = document.querySelectorAll("p, .imageblock :not(img), .admonitionblock")
      // console.log(sections);
      let links = document.querySelectorAll(".xref");
      let hrefs = []
      for (var i = 0; i < links.length; i++) {
        hrefs.push(links[i].href)
      }

      let images = document.querySelectorAll("img");
      let sources = []
      for (var i = 0; i < images.length; i++) {
        sources.push(images[i].src)
      }

      for (let k = 0; k < sections.length; k++) {

        // console.log(sections[k]);
        let pattern = new RegExp("(" + searchText + ")", "gi");





        sections[k].innerHTML = sections[k].innerHTML.replace(pattern, "<mark>$1</mark>");



      }
      let new_links = document.querySelectorAll(".xref");
      for (var i = 0; i < new_links.length; i++) {
        new_links[i].href = hrefs[i]
      }
      let new_images = document.querySelectorAll("img");
      for (var i = 0; i < new_images.length; i++) {
        new_images[i].src = sources[i]
      }
      // console.log(document.querySelector("mark"));
      if (document.querySelector("mark") !== undefined && document.querySelector("mark") != null) {
        let scrollPos = document.querySelector("mark").offsetTop - 200;
        console.log(scrollPos);
        window.scroll({
          top: scrollPos,
          behavior: "auto"
        });
      }


    }



  }


  function initSearch(lunr, data) {
    const start = performance.now();
    const index = {
      index: lunr.Index.load(data.index),
      store: data.store
    };
    enableSearchInput(true);
    searchInput.dispatchEvent(
      new CustomEvent('loadedindex', {
        detail: {
          took: performance.now() - start,
        },
      })
    );
    searchInput.addEventListener(
      'keydown',
      debounce(function (e) {
        if (e.key === 'Escape' || e.key === 'Esc') return clearSearchResults(true)
        executeSearch(index);
      }, 100)
    );
    searchInput.addEventListener('click', confineEvent);
    searchResultContainer.addEventListener('click', confineEvent);
    if (componentFilterInput) {
      componentFilterInput.parentElement.addEventListener('click', confineEvent);
      componentFilterInput.addEventListener('change', (e) => toggleFilter(e, index));
    }
    document.documentElement.addEventListener('click', clearSearchResults);

    highliteMatches()


  }

  // disable the search input until the index is loaded
  enableSearchInput(false);

  exports.initSearch = initSearch;

  Object.defineProperty(exports, '__esModule', {
    value: true
  });

}));