---
layout: post
title: 使用xib来自定义UITableViewCell (Swift项目)
description: ""
headline: ""
categories: tech
tags: 
  - 技术
  - 前端
  - iOS
comments: true
mathjax: null
featured: false
published: true
date: 2015-7-21
imagefeature: bg/bg_maple.jpg

---
之前在使用UITableView时，总是在Storeboard里直接把property cell放到相应ViewController的Table里。如果一个cell需要在其他ViewController里进行复用，我们可以直接在IB里进行复制，粘贴，这样虽然比较简单，但以后项目维护过程中，某个cell发生了改变，要重复该操作，且不能遗漏修改。可以在xib中设计cell来进行复用。

<!--more--> 

操作步骤：

### 1. 新建一个empty xib文件 ###
File -> New File -> User Interface -> `Empty`

这里记得选用 Empty 来创建一个空的xib文件。

### 2. 在IB中设计cell ###
打开刚才新建的xib文件（这里暂时命名为CellUI），拖入一个`Table View Cell`，自定义其size，然后根据需要设计该cell。

这个cell就是我们的自定义cell了。

### 3. 使用cell ###
我们可以新建一个继承与UITableViewcell的类(TabLocationTableCell),将cell中的文本等元素与其关联。

在TableView的delegate里，我们自定义个resueID，修改cellForRowAtIndexPath

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: AnyObject? = self.tableView.dequeueReusableCellWithIdentifier(self.resueCellID) //1
        if nil == cell {
            let viewList = NSBundle.mainBundle().loadNibNamed("CellUI", owner: self, options: nil) //2
            for obj in viewList {
                if obj is TabLocationTableCell {
                    cell = obj as? TabLocationTableCell //3
                    break
                }
            }
        }

        if let cell = cell as? TabLocationTableCell {
            cell.nameTxt.text = self.jsonDataList![indexPath.row]["GrpName"].stringValue //4
            return cell
        }

        println("never goes here") //5
        return UITableViewCell()
    }

代码说明：

1. 使用 `func dequeueReusableCellWithIdentifier(_ identifier: String) -> AnyObject?` 来获取一个可用的cell。注意这里没有传入 `indexPath`
2. 如果没有可复用的cell，则加载xib，生成一个该cell
3. 一个xib中可以放入多个view，从中找到我们需要的cell
4. 可以对改cell内容进行赋值
5. 程序应该永远运行不到这里，如果出现此信息，重新检查你的代码


** 补充： **
采用这种方法时，不需要调用 `self.tableView.registerClass`。

以前在storyboard里直接设计cell时，我们都会使用`dequeueReusableCellWithIdentifier:forIndexPath:` 来获取可复用的cell，该方法才需要提前registerClass （IB里可以指定ID，会自动帮我们做）。否则，会收到错误：

Terminating app due to uncaught exception 'NSInternalInconsistencyException', reason: 'unable to dequeue a cell with identifier locationCell - must register a nib or a class for the identifier or connect a prototype cell in a storyboard'

(完)

