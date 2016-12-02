| import 'components/catalog.tag'

| import './brand-new-modal.tag'

brands-list

    catalog(search='true', sortable='true', object='Brand', cols='{ cols }', reload='true', store='brands-list',
    add='{ permission(add, "products", "0100") }',
    remove='{ permission(remove, "products", "0001") }',
    dblclick='{ permission(brandOpen, "products", "1000") }')
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='imageUrlPreview')
                img(width='32px', height='32px', src='{ row.imageUrlPreview }')
            datatable-cell(name='name') { row.name }

    style(scoped).
        .table td {
            vertical-align: middle !important;
        }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'Brand'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'imageUrlPreview', value: 'Картинка'},
            {name: 'name', value: 'Наименование' },
        ]

        self.add = e => {
            modals.create('brand-new-modal', {
                type: 'modal-primary',
                submit() {
                    var _this = this
                    var params = {name: _this.name.value}
                    _this.error = _this.validation.validate(_this.item, _this.rules)

                    if (!_this.error) {
                        API.request({
                            object: 'Brand',
                            method: 'Save',
                            data: params,
                            success(response) {
                                popups.create({title: 'Успех!', text: 'Бренд добавлен!', style: 'popup-success'})
                                _this.modalHide()
                                observable.trigger('brands-reload')
                            }
                        })
                    }
                }
            })
        }


        self.brandOpen = e => {
            riot.route(`/products/brands/${e.item.row.id}`)
        }

        observable.on('brands-reload', () => {
            self.tags.catalog.reload()
        })