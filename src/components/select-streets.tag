| import once from 'lodash/once'

select-streets

	input(class='{ "open": isOpen && !opts.disabled }', type='text', onfocus='{ onFocus }',
		oninput='{ opts.onInput }', value='{ opts.value }')
	div.results(show='{ isOpen && !opts.disabled }', onchange='return false;')
		ul(if='{ opts.values.length }')
			li(each='{ value, i in opts.values }', onclick='{ itemClick }', value='{ i }' no-reorder)
				| { value.typeShort }. { value.name }

	style(scoped).
		:scope {
			display: block;
			width: 100%;
			vertical-align: middle;
			height: 34px;
			position: relative;
		}

		:scope > input {
			padding: 6px 12px;
			font-size: 14px;
			border: 1px solid #ccc;
			border-radius: 4px;
			background-color: #fff;
			}

			.text {
				margin: 6px 12px;
				font-size: 14px;
				background-color: #fff;
			}

		:scope > input.open {
			border: 1px solid #66afe9;
			border-radius: 4px 4px 0 0;
			outline: 0;
			-webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);
			box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);
			}

		:scope .results {
			outline: 0;
			-webkit-box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);
			box-shadow: inset 0 1px 1px rgba(0,0,0,.075),0 0 8px rgba(102,175,233,.6);
			border-radius: 0 0 4px 4px;
			z-index: 10;
			position: absolute;
			background-color: #fff;
			background-image: none;
			border-left: 1px solid #66afe9;
			border-right: 1px solid #66afe9;
			border-bottom: 1px solid #66afe9;
			left: 0;
			right: 0;
			}

		:scope .results > .text {
			display: block;
			position: relative;
			padding: 4px;
			}

		:scope .results > .text input {
			border: 1px solid #ccc;
			width: 100%;
			padding: 4px;
			height: 28px;
			}

		:scope ul {
			list-style: none;
			margin: 0;
			padding: 6px 0px;
			font-size: 14px;
			overflow-x: hidden;
			overflow-y: auto;
			max-height: 200px;
			}

		:scope ul li {
			padding: 4px 12px;
			cursor: pointer;
			}

		:scope ul li:hover {
			color: #fff;
			background-color: #66afe9;
			}

			.form-inline :scope {
				display: inline-block;
				width: auto;
				vertical-align: middle;
			}

	script(type='text/babel').

		var self = this

		const handleClickOutside = e => {
			if (!self.root.contains(e.target))
				self.close()
			self.update()
		}

		self.open = () => {
			self.isOpen = true
			self.trigger('open')
		}

		self.close = () => {
			self.isOpen = false
			self.trigger('close')
		}

		self.onFocus = () => {
			self.open()
		}

		self.itemClick = (e) => {
			let index = e.target.value
			if (typeof(opts.set) == 'function')
				opts.set.bind(this)(opts.values[index].name, opts.values[index].type)
			self.close()
		}

		self.one('mount', () => {
			self.close()
			document.addEventListener('mousedown', handleClickOutside)
		})


		this.on('unmount', () => {
			document.removeEventListener('mousedown', handleClickOutside)
		})

