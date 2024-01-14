import { WeiqiCore, mapBoardPoint2Str } from '../../weiqiCore/index';

const BoardWidth = 1080;
const LineWidth = 1;
const LineNum = 20;

const boardPadding = BoardWidth / (LineNum - 2) * 3 / 4;

const Width = BoardWidth - 2 * boardPadding;

const xingwei = [
  [3, 3], [9, 3], [15, 3],
  [3, 9], [9, 9], [15, 9],
  [3, 15], [9, 15], [15, 15],
]

@Entry
@Component
struct Index {
  @State message: string = 'Hello World'
  @State dpiBi: number = vp2px(Width) / Width
  @State gridSize: number = (Width - (LineNum * LineWidth)) / (LineNum - 2) / this.dpiBi
  private xingweiRadiu = this.gridSize * 3 / 9;
  private shiliRadiu = this.gridSize * 3 / 8;
  private stoneRadiu = this.gridSize * 4 / 5;
  private paddingOffset = boardPadding / this.dpiBi;
  @State clickOffset: Array<number> = [0, 0]
  @State clickPos: Array<number> = [0, 0]
  private core: WeiqiCore = new WeiqiCore(19);
  @State estimate: {
    estimateMode: boolean;
    estimateRes: Array<{
      x: number;
      y: number;
      color: number
    }>
  } = { estimateMode: false, estimateRes: [] };
  @State board: Array<Array<number>> = this.core.getBoard();

  aboutToAppear() {
    this.core.onBoardChange((board) => {
      this.board = board;
      // this.clickPos = [-1, -1];
    })
  }

  handleReset() {
    this.core = new WeiqiCore(19);
    this.core.onBoardChange((board) => {
      this.board = board;
      // this.clickPos = [-1, -1];
    })
    this.board = this.core.getBoard();
    this.estimate = { estimateRes: [], estimateMode: false }
  }

  handleEstimate() {

    const {estimateMode} = this.estimate;

    if (estimateMode) {
      this.estimate = { estimateMode: false, estimateRes: [] }
      return;
    }

    const estimateRes_ = this.core.estimate(false);

    const estimateArr: Array<{
      x: number;
      y: number;
      color: number
    }> = [];

    estimateRes_.forEach((yrow, yIndex) => {
      yrow.forEach((v, xIndex) => {
        if (v !== 0) {
          estimateArr.push({ x: xIndex, y: yIndex, color: v })
        }
      })
    });

    this.estimate = { estimateMode: true, estimateRes: estimateArr };

  }

  handleClick(e: ClickEvent) {
    const {x,y} = e;

    // 这里应该四舍五入更科学
    const xPos = Math.round((x - this.paddingOffset) / (this.gridSize + LineWidth / this.dpiBi));
    const yPos = Math.round((y - this.paddingOffset) / (this.gridSize + LineWidth / this.dpiBi));

    if (xPos < 0 || yPos < 0 || xPos >= 19 || yPos >= 19) {
      return;
    }

    this.clickOffset = [x, y];
    this.clickPos = [xPos, yPos];

    this.estimate = { estimateMode: false, estimateRes: [] }

    const res = this.core.play(mapBoardPoint2Str({ x: xPos, y: yPos }, 19));

    console.info('-------weiqicore play', res?.length)

  }

  getStones() {
    const stones: Array<{
      x: number,
      y: number,
      color: number
    }> = [];
    this.board.forEach((yrow, yIndex) => {
      yrow.forEach((v, xIndex) => {
        if (v !== 0) {
          stones.push({ x: xIndex, y: yIndex, color: v })
        }
      })
    });

    console.log('count:', stones.length, JSON.stringify(stones));

    return stones;
  }

  build() {
    // const Circles = [1,1,1,1,1].map(item=>Circle({ width: 75, height: 75 }).fill('#E87361'))

    Row({ space: 10 }) {
      Column() {
        // 创建一个宽高都为150的shape组件，背景色为黄色，一个宽高都为75的viewport。用一个蓝色的矩形来填充viewport，在viewport中绘制一个直径为75的圆。
        // 绘制结束，viewport会根据组件宽高放大两倍
        // Text('shape内放大的Circle组件')
        Text(`x: ${this.clickOffset[0]}; y: ${this.clickOffset[1]}`)
        Text(`pos: ${this.clickPos[0]},${this.clickPos[1]}`)

        Shape() {
          // Rect().width('100%').height('100%').fill('#0097D4')
          ForEach(new Array(LineNum).fill(1), (_, index) => {
            Rect()
              .width(Width / this.dpiBi)
              .height(LineWidth / this.dpiBi)
              .fill('#fff000')
              .margin({
                top: index * (this.gridSize + LineWidth / this.dpiBi) + this.paddingOffset,
                left: this.paddingOffset
              })
            Rect()
              .width(LineWidth / this.dpiBi)
              .height(Width / this.dpiBi)
              .fill('#fff000')
              .margin({
                left: index * (this.gridSize + LineWidth / this.dpiBi) + this.paddingOffset,
                top: this.paddingOffset
              })
          }, (item) => item)

          ForEach(xingwei, (item) => {
            Circle({ width: this.xingweiRadiu, height: this.xingweiRadiu })
              .fill("#E87361")
              .margin({
                left: item[0] * (this.gridSize + LineWidth / this.dpiBi) - this.xingweiRadiu / 2 + this.paddingOffset,
                top: item[1] * (this.gridSize + LineWidth / this.dpiBi) - this.xingweiRadiu / 2 + this.paddingOffset
              })
          }, (item) => item)

          ForEach(this.getStones(), (item) => {
            Circle({ width: this.stoneRadiu, height: this.stoneRadiu })
              .fill(item.color === -1 ? "#2e2726" : '#dcdff4')
              .margin({
                left: item.x * (this.gridSize + LineWidth / this.dpiBi) - this.stoneRadiu / 2 + this.paddingOffset,
                top: item.y * (this.gridSize + LineWidth / this.dpiBi) - this.stoneRadiu / 2 + this.paddingOffset
              })
          })

          if (this.estimate.estimateMode) {
            ForEach(this.estimate.estimateRes, (item) => {
              Circle({ width: this.shiliRadiu, height: this.shiliRadiu })
                .fill(item.color === -1 ? "#000" : '#fff')
                .margin({
                  left: item.x * (this.gridSize + LineWidth / this.dpiBi) - this.shiliRadiu / 2 + this.paddingOffset,
                  top: item.y * (this.gridSize + LineWidth / this.dpiBi) - this.shiliRadiu / 2 + this.paddingOffset
                })
            })
          }

        }
        .onClick((e) => {
          this.handleClick(e);
        })
        .backgroundColor('#0097D4')
        .width(BoardWidth / this.dpiBi).height(BoardWidth / this.dpiBi)

        Row() {
          Button('<', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {
            this.core.jumpPreStep();
          })
          Button('>', { type: ButtonType.Normal, stateEffect: true }).onClick(() => {
            this.core.jumpNextStep();
          })
          Button('reset', { type: ButtonType.Normal, stateEffect: true })
            .onClick(() => this.handleReset())
            .margin({ left: 20 })

          Button('estimate', { type: ButtonType.Normal, stateEffect: true })
            .onClick(() => this.handleEstimate())
            .margin({ left: 20 })
        }.margin({ top: 16 })
      }
    }
  }
}