| import 'components/catalog.tag'


news-list

    catalog(object='News', search='true', sortable='true', cols='{ cols }', reload='true',
        add='{ permission(add, "news", "0100") }',
        remove='{ permission(remove, "news", "0001") }',
        dblclick='{ permission(newsOpen, "news", "1000") }', store='news-list', new-filter='true')
        #{'yield'}(to='filters')
            .well.well-sm
                .form-inline
                    .form-group
                        label.control-label Категории
                        select.form-control(data-name='idCategory', onclick='{ parent.selectCategory }')
                            option(value='') Все
                            option(each='{ category, i in parent.newsCategories }', value='{ category.id }', no-reorder) { category.title }
        #{'yield'}(to='body')
            datatable-cell(name='id') { row.id }
            datatable-cell(name='imageUrlPreview')
                img(src='{ row.imageUrlPreview }', alt='', width='32', height='32')
            datatable-cell(name='date') { row.date }
            datatable-cell(name='name') { row.name }

    script(type='text/babel').
        var self = this

        self.mixin('permissions')
        self.mixin('remove')
        self.collection = 'News'

        self.cols = [
            {name: 'id', value: '#'},
            {name: 'imageFile', value: 'Фото'},
            {name: 'date', value: 'Дата публ.'},
            {name: 'name', value: 'Заголовок'}
        ]

        self.add = () => {
            if (self.selectedCategory)
                riot.route(`/news/new?category=${self.selectedCategory}&name=${self.selectedCategoryName}`)
            else
                riot.route('/news/new')
        }

        self.newsOpen = e => {
            riot.route(`/news/${e.item.row.id}`)
        }

        self.getNewsCategories = () => {
            API.request({
                object: 'NewsCategory',
                method: 'Fetch',
                success(response) {
                    self.newsCategories = response.items
                    self.update()
                }
            })
        }

        self.selectCategory = e => {
            self.selectedCategory = e.target.value || undefined
            self.selectedCategoryName = e.target.textContent || undefined
        }

        self.one('updated', () => {
            self.tags.catalog.on('reload', () => {
                self.getNewsCategories()
            })
        })

        observable.on('news-reload', () => {
            self.tags.catalog.reload()
        })

        self.getNewsCategories()


