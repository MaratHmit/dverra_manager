| import debounce from 'lodash/debounce'

setting-group
    form(onchange='{ change }')
        .row(each='{ item, i in items }')
            .col-md-12
                .form-group(if='{ item.type == "string" }')
                    label.control-label { item.name }
                    input.form-control(data-id='{ item.id }'  value='{ item.value }')

    script(type='text/babel').
        var self = this

        self.items = []

        observable.on('settings-reload', group => {
            if (group.values) {
                self.items = group.values
                return
            }

            let data = { filters: [{value: group.id, field: "idGroup"}] }
            API.request({
                object: 'Setting',
                method: 'Fetch',
                data: data,
                success(response) {
                    self.items = response.items
                    group.values = self.items
                    self.update()
                }
            })
        })

        var save = debounce(e => {
            API.request({
                object: 'SettingValue',
                method: 'Save',
                data: e,
                complete: () => self.update()
            })
        }, 600)

        self.change = e => {
            let data = {}
            let idSetting = e.target.dataset.id
            let index = 0

            self.items.forEach(function (item, i) {
                if (item.id == idSetting) {
                    index = i
                    data.id = item.idValue
                    data.idSetting = idSetting
                    data.value = e.target.value
                }
            })
            if (!data.idSetting)
                return;
            save(data)
        }
