| import 'pages/orders/orders-list.tag'
| import 'pages/orders/order-edit.tag'

orders
    orders-list(if='{ tab == "orders" && !edit }')
    order-edit(if='{ tab == "orders" && edit }')

    script(type='text/babel').
        var self = this

        self.edit = false
        self.notFound = false

        var route = riot.route.create()

        route('/orders', () => {
            self.edit = false
            self.tab = 'orders'
            self.notFound = false
            self.update()
        })

        route('/orders/([0-9]+)', id => {
            observable.trigger('orders-edit', id)
            self.edit = true
            self.notFound = false
            self.tab = 'orders'
            self.update()
        })

        route('/orders/new', function () {
            self.edit = true
            self.notFound = false
            self.tab = 'orders'
            observable.trigger('order-new')
            self.update()
        })

        route('/orders/*', tab => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/orders..', () => {
            self.notFound = true
            self.tab = 'orders'
            self.update()
            observable.trigger('not-found')
        })

        self.on('mount', function () {
            riot.route.exec()
        })
