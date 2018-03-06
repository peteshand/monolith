package mantle.util.signals;

/**
 * ...
 * @author Thomas Byrne
 */
#if swc
	typedef Signal<T, K> = org.osflash.signals.Signal;
	typedef Signal0 = org.osflash.signals.Signal;
	typedef Signal1<T> = org.osflash.signals.Signal;
	typedef Signal2<T, K> = org.osflash.signals.Signal;
#else
	typedef Signal<TSlot:msignal.Slot<Dynamic, Dynamic>, TListener> = msignal.Signal<TSlot, TListener>;
	typedef Signal0 = msignal.Signal.Signal0;
	typedef Signal1<T> = msignal.Signal.Signal1<T>;
	typedef Signal2<T, K> = msignal.Signal.Signal2<T, K>;
#end