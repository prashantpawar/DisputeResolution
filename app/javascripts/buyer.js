(function(angular) {
  'use strict';
  angular.module('buyer', ['accounts', 'contracts'])
    .component('buyer', {
      template: [
      '<div class="uk-width-1-1">',
      '    <h1>Buyer</h1>',
      '    <ng-outlet></ng-outlet>',
      '</div>'
      ].join(''),
      $routeConfig: [
        {path: '/', name: 'BuyerSetup', component: 'buyerSetup', useAsDefault: true},
        {path: '/:contractAddress', name: 'BuyerMain', component: 'buyerMain'}
      ]
    })

    .component('buyerSetup', {
      templateUrl: 'partials/buyer.html',
      controller: buyerSetupComponent
    })

    .component('buyerMain', {
      templateUrl: 'partials/buyerMain.html',
      controller: buyerMainComponent
    });

    function buyerSetupComponent(accountService, escrowService) {
        var $ctrl = this;
        $ctrl.release = function release() {
            escrowService.release(accountService.getSelectedAccount());
        };
        this.$routerOnActivate = function(next) {
        };
    }

    function buyerMainComponent() {
        var $buyerMainCtrl = this;
        this.$routerOnActivate = function(next) {
        };
    }
})(window.angular);
