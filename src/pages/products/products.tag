| import 'pages/products/products/products-list.tag'
| import 'pages/products/products/product-edit.tag'
| import 'pages/products/groups/groups-list.tag'
| import 'pages/products/groups/group-edit.tag'
| import 'pages/products/brands/brands-list.tag'
| import 'pages/products/brands/brand-edit.tag'
| import 'pages/products/parameters/parameters-groups-list.tag'
| import 'pages/products/parameters/parameters-list.tag'
| import 'pages/products/parameters/parameter-edit.tag'
| import 'pages/products/discounts/discounts-list.tag'
| import 'pages/products/discounts/discount-edit.tag'
| import 'pages/products/coupons/coupons-list.tag'
| import 'pages/products/coupons/coupon-edit.tag'
| import 'pages/products/shop-services/shop-services.tag'
| import 'pages/products/shop-services/shop-service-edit.tag'
| import 'pages/products/products-types/products-types-list.tag'
| import 'pages/products/labels/labels-list.tag'
| import 'pages/products/labels/label-edit.tag'

products
    ul(if='{ !edit }').nav.nav-tabs.m-b-2
        li(each='{ tabs }', class='{ active: name == tab }')
            a(href='#products/{ link }')
                span { title }

    .column
        products-list(if='{ tab == "products" && !edit }')
        product-edit(if='{ tab == "products" && edit }')

        specials-list(if='{ tab == "specials" && !edit }')

        groups-list(if='{ tab == "categories" && !edit }')
        group-edit(if='{ tab == "categories" && edit }')

        labels-list(if='{ tab == "labels" && !edit }')
        label-edit(if='{ tab == "labels" && edit }')

        products-types-list(if='{ tab == "types" && !edit }')

        brands-list(if='{ tab == "brands" && !edit }')
        brand-edit(if='{ tab == "brands" && edit }')

        parameters-groups-list(if='{ tab == "parameters-groups" && !edit }')

        parameters-list(if='{ tab == "parameters" && !edit }')
        parameter-edit(if='{ tab == "parameters" && edit }')

        modifications-list(if='{ tab == "modifications" && !edit }')
        modification-edit(if='{ tab == "modifications" && edit }')

        discounts-list(if='{ tab == "discounts" && !edit }')
        discount-edit(if='{ tab == "discounts" && edit }')

        shop-services(if='{ tab == "shop-services" && !edit }')
        shop-service-edit(if='{ tab == "shop-services" && edit }')

        coupons-list(if='{ tab == "coupons" && !edit }')
        coupon-edit(if='{ tab == "coupons" && edit }')

    script(type='text/babel').
        var self = this

        self.edit = false
        self.tab = ''

        self.tabs = [
            {title: 'Товары', name: 'products', link: ''},
            {title: 'Каталог', name: 'categories', link: 'categories'},
            {title: 'Услуги', name: 'shop-services', link: 'shop-services'},
            {title: 'Ярлыки', name: 'labels', link: 'labels'},
            {title: 'Типы товаров', name: 'types', link: 'types'},
            {title: 'Бренды', name: 'brands', link: 'brands'},
            {title: 'Группы параметров', name: 'parameters-groups', link: 'parameters-groups'},
            {title: 'Параметры', name: 'parameters', link: 'parameters'},
            {title: 'Скидки', name: 'discounts', link: 'discounts'},
            {title: 'Купоны', name: 'coupons', link: 'coupons'},
        ]

        var route = riot.route.create()

        route('/products/([0-9]+)', id => {
            self.tab = 'products'
            observable.trigger('products-edit', id)
            self.edit = true
            self.update()
        })

        route('/products/*/([0-9]+)', (tab, id) => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: true, tab: tab})
                observable.trigger(tab + '-edit', id)
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/products/multi..', () => {
            let q = riot.route.query()
            let ids = q.ids.split(',')
            self.tab = 'products'
            observable.trigger('products-multi-edit', ids)
            self.edit = true
            self.update()
        })

        route('/products/clone..', () => {
            let q = riot.route.query()
            let id = q.id
            self.tab = 'products'
            observable.trigger('products-clone', id)
            self.edit = true
            self.update()
        })

        route('/products/categories/multi..', () => {
            let q = riot.route.query()
            let ids = q.ids.split(',')
            self.tab = 'categories'
            observable.trigger('categories-multi-edit', ids)
            self.edit = true
            self.update()
        })

        route('/products/modifications/new', tab => {
            self.update({edit: true, tab: 'modifications'})
            observable.trigger('modifications-new')
        })

        route('/products/discounts/new', tab => {
            self.update({edit: true, tab: 'discounts'})
            observable.trigger('discounts-new')
        })

        route('/products/coupons/new', tab => {
            self.update({edit: true, tab: 'coupons'})
            observable.trigger('coupons-new')
        })

        route('/products/labels/new', tab => {
            self.update({edit: true, tab: 'labels'})
            observable.trigger('label-new')
        })

        route('/products/shop-services/new', tab => {
            self.update({edit: true, tab: 'shop-services'})
            observable.trigger('shop-service-new')
        })

        route('/products', () => {
            self.edit = false
            self.tab = 'products'
            self.update()
        })

        route('/products/*', tab => {
            if (self.tabs.map(i => i.name).indexOf(tab) !== -1) {
                self.update({edit: false, tab: tab})
            } else {
                self.update({edit: true, tab: 'not-found'})
                observable.trigger('not-found')
            }
        })

        route('/products..', () => {
            self.update({edit: true, tab: 'not-found'})
            observable.trigger('not-found')
        })

        self.on('mount', () => {
            riot.route.exec()
        })