| import debounce from 'lodash/debounce'
| import 'pages/settings/setting-group.tag'

settings-main
    loader(if='{ loader }')
    virtual(hide='{ loader }')
        .row
            .col-md-12
                ul.nav.nav-tabs.m-b-2(if='{ groups.length > 0 }')
                    li(each='{ item, i in groups }', class='{ active: activeTab === i }')
                        a(onclick='{ changeTab }')
                            span { item.name }
        .row
            .col-md-12
                setting-group(if='{ groups.length > 0 }')

    script(type='text/babel').
        var self = this,
            route = riot.route.create()

        self.groups = []
        self.mixin('permissions')
        self.mixin('change')

        self.activeTab = 0

        self.changeTab = e => {
            self.activeTab = e.item.i
            observable.trigger('settings-reload', self.groups[e.item.i])
        }

        self.reload = () => {
            self.loader = true
            self.update()

            API.request({
                object: 'SettingGroup',
                method: 'Fetch',
                success(response) {
                    self.groups = response.items
                },
                complete() {
                    self.loader = false
                    self.update()
                    if (self.groups.length)
                        observable.trigger('settings-reload', self.groups[self.activeTab])
                }
            })
        }

        route('/settings/main', () => {
            self.reload()
        })

        self.on('mount', () => {
            riot.route.exec()
        })

