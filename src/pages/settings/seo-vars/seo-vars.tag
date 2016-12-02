| import 'pages/settings/seo-vars/seo-var-modal.tag'

seo-vars
    h4 Макропеременные для метатегов

    catalog(object='SeoVariable', cols='{ cols }', reload='true',
    add='{ permission(addEdit, "settings", "0100") }',
    remove='{ permission(remove, "settings", "0001") }',
    dblclick='{ permission(addEdit, "settings", "1010") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='name') { row.name }
            datatable-cell(name='value') { row.value }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')

        self.collection = "SeoVariable"

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'name', value: 'Наименование'},
            {name: 'value', value: 'Значение'},
        ]

        self.addEdit = e => {
            var id
            if (e.item && e.item.row) {
                id = e.item.row.id
            }

            modals.create('seo-var-modal', {
                type: 'modal-primary',
                id: id,
                submit() {
                    var _this = this
                    var params = _this.item

                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'SeoVariable',
                            method: 'Save',
                            data: params,
                            success(response) {
                                _this.modalHide()
                                self.tags.catalog.reload()
                             }
                        })
                    }
                }
            })
        }

        observable.on('seo-vars-reload', () => {
            self.tags.catalog.reload()
        })
