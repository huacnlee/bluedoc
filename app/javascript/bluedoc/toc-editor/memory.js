// Only records the changes caused by the addition , deletion and sorts of the directory
export default class memery {
  constructor() {
    this.list = [];
    this.index = -1;
  }

  push = (item) => {
    this.list.splice(this.index + 1, this.list.length, item);
    this.index = this.list.length - 1;
  }

  undo = () => {
    if (this.index > 0) {
      this.index = this.index - 1;
      return this.list[this.index];
    }
    return false;
  }

  redo = () => {
    if (this.index <= this.list.length) {
      this.index = this.index + 1;
      return this.list[this.index];
    }
    return false;
  }
}
